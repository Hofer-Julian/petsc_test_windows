static char help[] = "Runaway electron model with Landau collision operator\n\n";

#include <petscdmplex.h>
#include <petsclandau.h>
#include <petscts.h>
#include <petscds.h>

/* data for runaway electron model */
typedef struct REctx_struct {
  PetscErrorCode (*test)(TS, Vec, DM, PetscInt, PetscReal, PetscBool,  LandauCtx *, struct REctx_struct *);
  PetscErrorCode (*impuritySrcRate)(PetscReal, PetscReal *, LandauCtx*);
  PetscErrorCode (*E)(Vec, Vec, PetscInt, PetscReal, LandauCtx*, PetscReal *);
  PetscReal     T_cold;        /* temperature of newly ionized electrons and impurity ions */
  PetscReal     ion_potential; /* ionization potential of impurity */
  PetscReal     Ne_ion;        /* effective number of electrons shed in ioization of impurity */
  PetscReal     Ez_initial;
  PetscReal     L;             /* inductance */
  Vec           X_0;
  PetscInt      imp_idx;       /* index for impurity ionizing sink */
  PetscReal     pulse_start;
  PetscReal     pulse_width;
  PetscReal     pulse_rate;
  PetscReal     current_rate;
  PetscInt      plotIdx;
  PetscInt      plotStep;
  PetscInt      idx; /* cache */
  PetscReal     j; /* cache */
  PetscReal     plotDt;
  PetscBool     plotting;
  PetscBool     use_spitzer_eta;
  Vec           imp_src;
} REctx;

static const PetscReal kev_joul = 6.241506479963235e+15; /* 1/1000e */
static PetscBool s_quarter3DDomain_notused = PETSC_FALSE;

#define RE_CUT 5.
/* < v, u_re * v * q > */
static void f0_j_re(PetscInt dim, PetscInt Nf, PetscInt NfAux,
                    const PetscInt uOff[], const PetscInt uOff_x[], const PetscScalar u[], const PetscScalar u_t[], const PetscScalar u_x[],
                    const PetscInt aOff[], const PetscInt aOff_x[], const PetscScalar a[], const PetscScalar a_t[], const PetscScalar a_x[],
                    PetscReal t, const PetscReal x[],  PetscInt numConstants, const PetscScalar constants[], PetscScalar *f0)
{
  PetscReal n_e = PetscRealPart(u[0]);
  if (dim==2) {
    if (x[1] > RE_CUT || x[1] < -RE_CUT) { /* simply a cutoff for REs. v_|| > 3 v(T_e) */
      *f0 = n_e * 2.*PETSC_PI*x[0] * x[1] * constants[0]; /* n * r * v_|| * q */
    } else {
      *f0 = 0;
    }
  } else {
    if (x[2] > RE_CUT || x[2] < -RE_CUT) { /* simply a cutoff for REs. v_|| > 3 v(T_e) */
      *f0 = n_e                * x[2] * constants[0];
      if (s_quarter3DDomain_notused) *f0 *= 4.0;
    } else {
      *f0 = 0;
    }
  }
}

/* sum < v, u*v*q > */
static void f0_jz_sum(PetscInt dim, PetscInt Nf, PetscInt NfAux,
                   const PetscInt uOff[], const PetscInt uOff_x[], const PetscScalar u[], const PetscScalar u_t[], const PetscScalar u_x[],
                   const PetscInt aOff[], const PetscInt aOff_x[], const PetscScalar a[], const PetscScalar a_t[], const PetscScalar a_x[],
                   PetscReal t, const PetscReal x[],  PetscInt numConstants, const PetscScalar constants[], PetscScalar *f0)
{
  PetscInt ii;
  f0[0] = 0;
  if (dim==2) {
    for (ii=0;ii<numConstants;ii++) f0[0] += u[ii] * 2.*PETSC_PI*x[0] * x[1] * constants[ii]; /* n * r * v_|| * q */
  } else {
    for (ii=0;ii<numConstants;ii++) f0[0] += u[ii]                * x[2] * constants[ii]; /* n * v_|| * q  */
    if (s_quarter3DDomain_notused) *f0 *= 4.0;
  }
}

/* < v, n_e > */
static void f0_n(PetscInt dim, PetscInt Nf, PetscInt NfAux,
                  const PetscInt uOff[], const PetscInt uOff_x[], const PetscScalar u[], const PetscScalar u_t[], const PetscScalar u_x[],
                  const PetscInt aOff[], const PetscInt aOff_x[], const PetscScalar a[], const PetscScalar a_t[], const PetscScalar a_x[],
                  PetscReal t, const PetscReal x[],  PetscInt numConstants, const PetscScalar constants[], PetscScalar *f0)
{
  PetscInt ii = (PetscInt)PetscRealPart(constants[0]);
  if (dim==2) f0[0] = 2.*PETSC_PI*x[0]*u[ii];
  else {
    f0[0] =                        u[ii];
    if (s_quarter3DDomain_notused) f0[0] *= 4.0;
  }
}

/* < v, n_e v_|| > */
static void f0_vz(PetscInt dim, PetscInt Nf, PetscInt NfAux,
                   const PetscInt uOff[], const PetscInt uOff_x[], const PetscScalar u[], const PetscScalar u_t[], const PetscScalar u_x[],
                   const PetscInt aOff[], const PetscInt aOff_x[], const PetscScalar a[], const PetscScalar a_t[], const PetscScalar a_x[],
                   PetscReal t, const PetscReal x[],  PetscInt numConstants, const PetscScalar constants[], PetscScalar *f0)
{
  PetscInt ii = (PetscInt)PetscRealPart(constants[0]);
  if (dim==2) f0[0] = u[ii] * 2.*PETSC_PI*x[0] * x[1]; /* n r v_|| */
  else {
    f0[0] =           u[ii] *                x[2]; /* n v_|| */
    if (s_quarter3DDomain_notused) f0[0] *= 4.0;
  }
}

/* < v, n_e (v-shift) > */
static void f0_ve_shift(PetscInt dim, PetscInt Nf, PetscInt NfAux,
                         const PetscInt uOff[], const PetscInt uOff_x[], const PetscScalar u[], const PetscScalar u_t[], const PetscScalar u_x[],
                         const PetscInt aOff[], const PetscInt aOff_x[], const PetscScalar a[], const PetscScalar a_t[], const PetscScalar a_x[],
                         PetscReal t, const PetscReal x[],  PetscInt numConstants, const PetscScalar constants[], PetscScalar *f0)
{
  PetscReal vz = numConstants==1 ? PetscRealPart(constants[0]) : 0;
  if (dim==2) *f0 = u[0] * 2.*PETSC_PI*x[0] * PetscSqrtReal(x[0]*x[0] + (x[1]-vz)*(x[1]-vz));             /* n r v */
  else {
    *f0 =           u[0] *                PetscSqrtReal(x[0]*x[0] + x[1]*x[1] + (x[2]-vz)*(x[2]-vz)); /* n v */
    if (s_quarter3DDomain_notused) *f0 *= 4.0;
  }
}

static PetscErrorCode getTe_kev(DM plex, Vec X, PetscReal *a_n, PetscReal *a_Tkev)
{
  PetscErrorCode ierr;
  LandauCtx      *ctx;

  PetscFunctionBeginUser;
  ierr = DMGetApplicationContext(plex, &ctx);CHKERRQ(ierr);
  {
    PetscDS        prob;
    PetscReal      v2, v, n;
    PetscScalar    tt[LANDAU_MAX_SPECIES],user[2] = {0.,ctx->charges[0]}, vz;
    ierr = DMGetDS(plex, &prob);CHKERRQ(ierr);
    ierr = PetscDSSetConstants(prob, 2, user);CHKERRQ(ierr);
    ierr = PetscDSSetObjective(prob, 0, &f0_n);CHKERRQ(ierr);
    ierr = DMPlexComputeIntegralFEM(plex,X,tt,NULL);CHKERRQ(ierr);
    n = ctx->n_0*PetscRealPart(tt[0]);
    ierr = PetscDSSetObjective(prob, 0, &f0_vz);CHKERRQ(ierr);
    ierr = DMPlexComputeIntegralFEM(plex,X,tt,NULL);CHKERRQ(ierr);
    vz = ctx->n_0*PetscRealPart(tt[0])/n; /* non-dimensional */
    /* remove drift */
    ierr = PetscDSSetConstants(prob, 1, &vz);CHKERRQ(ierr);
    ierr = PetscDSSetObjective(prob, 0, &f0_ve_shift);CHKERRQ(ierr);
    ierr = DMPlexComputeIntegralFEM(plex,X,tt,NULL);CHKERRQ(ierr);
    v = ctx->n_0*ctx->v_0*PetscRealPart(tt[0])/n;         /* remove number density to get velocity */
    v2 = PetscSqr(v);                      /* use real space: m^2 / s^2 */
    if (a_Tkev) *a_Tkev = (v2*ctx->masses[0]*PETSC_PI/8)*kev_joul; /* temperature in kev */
    if (a_n) *a_n = n;
  }
  PetscFunctionReturn(0);
}
 /* CalculateE - Calculate the electric field  */
 /*  T        -- Electron temperature  */
 /*  n        -- Electron density  */
 /*  lnLambda --   */
 /*  eps0     --  */
 /*  E        -- output E, input \hat E */
static PetscReal CalculateE(PetscReal Tev, PetscReal n, PetscReal lnLambda, PetscReal eps0, PetscReal *E)
{
  PetscReal c,e,m;

  PetscFunctionBegin;
  c = 299792458;
  e = 1.602176e-19;
  m = 9.10938e-31;
  if (1) {
    double Ec, Ehat = *E, betath = PetscSqrtReal(2*Tev*e/(m*c*c)), j0 = Ehat * 7/(PetscSqrtReal(2)*2) * PetscPowReal(betath,3) * n * e * c;
    Ec = n*lnLambda*PetscPowReal(e,3) / (4*PETSC_PI*PetscPowReal(eps0,2)*m*c*c);
    *E = Ec;
    PetscPrintf(PETSC_COMM_WORLD, "CalculateE j0=%g Ec = %g\n",j0,Ec);
  } else {
    PetscReal Ed, vth;
    vth = PetscSqrtReal(8*Tev*e/(m*PETSC_PI));
    Ed =  n*lnLambda*PetscPowReal(e,3) / (4*PETSC_PI*PetscPowReal(eps0,2)*m*vth*vth);
    *E = Ed;
  }
  PetscFunctionReturn(0);
}

static PetscReal Spitzer(PetscReal m_e, PetscReal e, PetscReal Z, PetscReal epsilon0,  PetscReal lnLam, PetscReal kTe_joules)
{
  PetscReal Fz = (1+1.198*Z+0.222*Z*Z)/(1+2.966*Z+0.753*Z*Z), eta;
  eta = Fz*4./3.*PetscSqrtReal(2.*PETSC_PI)*Z*PetscSqrtReal(m_e)*PetscSqr(e)*lnLam*PetscPowReal(4*PETSC_PI*epsilon0,-2.)*PetscPowReal(kTe_joules,-1.5);
  return eta;
}

/*  */
static PetscErrorCode testNone(TS ts, Vec X, DM plex, PetscInt stepi, PetscReal time, PetscBool islast, LandauCtx *ctx, REctx *rectx)
{
  PetscFunctionBeginUser;
  PetscFunctionReturn(0);
}

/*  */
static PetscErrorCode testSpitzer(TS ts, Vec X, DM plex, PetscInt stepi, PetscReal time, PetscBool islast, LandauCtx *ctx, REctx *rectx)
{
  PetscErrorCode    ierr;
  PetscInt          ii;
  PetscDS           prob;
  static PetscReal  old_ratio = 0;
  PetscBool         done=PETSC_FALSE;
  PetscReal         J,J_re,spit_eta,Te_kev=0,E,ratio,Z,n_e;
  PetscScalar       user[2] = {0.,ctx->charges[0]}, constants[LANDAU_MAX_SPECIES],tt[LANDAU_MAX_SPECIES];

  PetscFunctionBeginUser;
  if (ctx->num_species<2) SETERRQ1(PETSC_COMM_SELF, PETSC_ERR_PLIB, "ctx->num_species %D < 2",ctx->num_species);
  for (ii=0;ii<ctx->num_species;ii++) constants[ii] = ctx->charges[ii];
  Z = -ctx->charges[1]/ctx->charges[0];
  ierr = DMGetDS(plex, &prob);CHKERRQ(ierr);
  ierr = PetscDSSetConstants(prob, 2, user);CHKERRQ(ierr);
  ierr = PetscDSSetObjective(prob, 0, &f0_n);CHKERRQ(ierr);
  ierr = DMPlexComputeIntegralFEM(plex,X,tt,NULL);CHKERRQ(ierr);
  n_e = PetscRealPart(tt[0])*ctx->n_0;
  ierr = PetscDSSetConstants(prob, ctx->num_species, constants);CHKERRQ(ierr);
  ierr = PetscDSSetObjective(prob, 0, &f0_jz_sum);CHKERRQ(ierr);
  ierr = DMPlexComputeIntegralFEM(plex,X,tt,NULL);CHKERRQ(ierr);
  J = -ctx->n_0*ctx->v_0*PetscRealPart(tt[0]);
  ierr = PetscDSSetConstants(prob, 1, &constants[0]);CHKERRQ(ierr);
  ierr = PetscDSSetObjective(prob, 0, &f0_j_re);CHKERRQ(ierr);
  ierr = DMPlexComputeIntegralFEM(plex,X,tt,NULL);CHKERRQ(ierr);
  J_re = -ctx->n_0*ctx->v_0*PetscRealPart(tt[0]);
  ierr = getTe_kev(plex, X, NULL, &Te_kev);CHKERRQ(ierr);
  spit_eta = Spitzer(ctx->masses[0],-ctx->charges[0],Z,ctx->epsilon0,ctx->lnLam,Te_kev/kev_joul); /* kev --> J (kT) */
  E = ctx->Ez; /* keep real E */
  ratio = E/J/spit_eta;
  done = PETSC_FALSE;
  ierr = PetscPrintf(PETSC_COMM_WORLD, "%s %4D) time=%10.3e n_e= %10.3e E= %10.3e J= %10.3e J_re= %10.3e %.3g %% Te_kev= %10.3e E/J to eta ratio=%g (diff=%g)\n",
                     done ? "DONE" : "testSpitzer",stepi,time,n_e/ctx->n_0,E,J,J_re,100*J_re/J,Te_kev,ratio,old_ratio-ratio);CHKERRQ(ierr);
  if (done) {
    ierr = TSSetConvergedReason(ts,TS_CONVERGED_USER);CHKERRQ(ierr);
    old_ratio = 0;
  } else {
    TSConvergedReason reason;
    ierr = TSGetConvergedReason(ts,&reason);CHKERRQ(ierr);
    old_ratio = ratio;
    if (reason) done = PETSC_TRUE;
  }
  PetscFunctionReturn(0);
}

static const double ppp = 2;
static void f0_0_diff_lp(PetscInt dim, PetscInt Nf, PetscInt NfAux,
                          const PetscInt uOff[], const PetscInt uOff_x[], const PetscScalar u[], const PetscScalar u_t[], const PetscScalar u_x[],
                          const PetscInt aOff[], const PetscInt aOff_x[], const PetscScalar a[], const PetscScalar a_t[], const PetscScalar a_x[],
                          PetscReal t, const PetscReal x[],  PetscInt numConstants, const PetscScalar constants[], PetscScalar *f0)
{
  LandauCtx       *ctx = (LandauCtx *)constants;
  REctx           *rectx = (REctx*)ctx->data;
  PetscInt        ii = rectx->idx, i;
  const PetscReal kT_m = ctx->k*ctx->thermal_temps[ii]/ctx->masses[ii]; /* kT/m */
  const PetscReal n = ctx->n[ii];
  PetscReal       diff, f_maxwell, v2 = 0, theta = 2*kT_m/(ctx->v_0*ctx->v_0); /* theta = 2kT/mc^2 */
  for (i = 0; i < dim; ++i) v2 += x[i]*x[i];
  f_maxwell = n*PetscPowReal(PETSC_PI*theta,-1.5)*(PetscExpReal(-v2/theta));
  diff = 2.*PETSC_PI*x[0]*(PetscRealPart(u[ii]) - f_maxwell);
  f0[0] = PetscPowReal(diff,ppp);
}
static void f0_0_maxwellian_lp(PetscInt dim, PetscInt Nf, PetscInt NfAux,
                          const PetscInt uOff[], const PetscInt uOff_x[], const PetscScalar u[], const PetscScalar u_t[], const PetscScalar u_x[],
                          const PetscInt aOff[], const PetscInt aOff_x[], const PetscScalar a[], const PetscScalar a_t[], const PetscScalar a_x[],
                          PetscReal t, const PetscReal x[],  PetscInt numConstants, const PetscScalar constants[], PetscScalar *f0)
{
  LandauCtx       *ctx = (LandauCtx *)constants;
  REctx           *rectx = (REctx*)ctx->data;
  PetscInt        ii = rectx->idx, i;
  const PetscReal kT_m = ctx->k*ctx->thermal_temps[ii]/ctx->masses[ii]; /* kT/m */
  const PetscReal n = ctx->n[ii];
  PetscReal       f_maxwell, v2 = 0, theta = 2*kT_m/(ctx->v_0*ctx->v_0); /* theta = 2kT/mc^2 */
  for (i = 0; i < dim; ++i) v2 += x[i]*x[i];
  f_maxwell = 2.*PETSC_PI*x[0] * n*PetscPowReal(PETSC_PI*theta,-1.5)*(PetscExpReal(-v2/theta));
  f0[0] = PetscPowReal(f_maxwell,ppp);
}

/*  */
static PetscErrorCode testStable(TS ts, Vec X, DM plex, PetscInt stepi, PetscReal time, PetscBool islast, LandauCtx *ctx, REctx *rectx)
{
  PetscErrorCode    ierr;
  PetscDS           prob;
  Vec               X2;
  PetscReal         ediff,idiff=0,lpm0,lpm1=1;
  PetscScalar       tt[LANDAU_MAX_SPECIES];
  DM                dm;

  PetscFunctionBeginUser;
  ierr = VecGetDM(X, &dm);CHKERRQ(ierr);
  ierr = DMGetDS(plex, &prob);CHKERRQ(ierr);
  ierr = VecDuplicate(X,&X2);CHKERRQ(ierr);
  ierr = VecCopy(X,X2);CHKERRQ(ierr);
  if (!rectx->X_0) {
    ierr = VecDuplicate(X,&rectx->X_0);CHKERRQ(ierr);
    ierr = VecCopy(X,rectx->X_0);CHKERRQ(ierr);
  }
  ierr = VecAXPY(X,-1.0,rectx->X_0);CHKERRQ(ierr);
  ierr = PetscDSSetConstants(prob, sizeof(LandauCtx)/sizeof(PetscScalar), (PetscScalar*)ctx);CHKERRQ(ierr);
  rectx->idx = 0;
  ierr = PetscDSSetObjective(prob, 0, &f0_0_diff_lp);CHKERRQ(ierr);
  ierr = DMPlexComputeIntegralFEM(plex,X2,tt,NULL);CHKERRQ(ierr);
  ediff = PetscPowReal(PetscRealPart(tt[0]),1./ppp);
  ierr = PetscDSSetObjective(prob, 0, &f0_0_maxwellian_lp);CHKERRQ(ierr);
  ierr = DMPlexComputeIntegralFEM(plex,X2,tt,NULL);CHKERRQ(ierr);
  lpm0 = PetscPowReal(PetscRealPart(tt[0]),1./ppp);
  if (ctx->num_species>1) {
    rectx->idx = 1;
    ierr = PetscDSSetObjective(prob, 0, &f0_0_diff_lp);CHKERRQ(ierr);
    ierr = DMPlexComputeIntegralFEM(plex,X2,tt,NULL);CHKERRQ(ierr);
    idiff = PetscPowReal(PetscRealPart(tt[0]),1./ppp);
    ierr = PetscDSSetObjective(prob, 0, &f0_0_maxwellian_lp);CHKERRQ(ierr);
    ierr = DMPlexComputeIntegralFEM(plex,X2,tt,NULL);CHKERRQ(ierr);
    lpm1 = PetscPowReal(PetscRealPart(tt[0]),1./ppp);
  }
  ierr = PetscPrintf(PETSC_COMM_WORLD, "%s %D) time=%10.3e n-%d norm electrons/max=%20.13e ions/max=%20.13e\n", "----",stepi,time,(int)ppp,ediff/lpm0,idiff/lpm1);CHKERRQ(ierr);
  /* view */
  ierr = VecViewFromOptions(X,NULL,"-vec_view_diff");CHKERRQ(ierr);
  ierr = VecCopy(X2,X);CHKERRQ(ierr);
  ierr = VecDestroy(&X2);CHKERRQ(ierr);
  if (islast) {
    ierr = VecDestroy(&rectx->X_0);CHKERRQ(ierr);
    rectx->X_0 = NULL;
  }
  PetscFunctionReturn(0);
}

/* E = eta_spitzer(Te-vz)*J */
static PetscErrorCode ESpitzer(Vec X,  Vec X_t,  PetscInt stepi, PetscReal time, LandauCtx *ctx, PetscReal *a_E)
{
  PetscErrorCode    ierr;
  PetscInt          ii;
  PetscReal         spit_eta,Te_kev,J,ratio;
  PetscScalar       tt[LANDAU_MAX_SPECIES], constants[LANDAU_MAX_SPECIES];
  PetscDS           prob;
  DM                dm,plex;
  REctx             *rectx = (REctx*)ctx->data;

  PetscFunctionBeginUser;
  for (ii=0;ii<ctx->num_species;ii++) constants[ii] = ctx->charges[ii];
  ierr = VecGetDM(X, &dm);CHKERRQ(ierr);
  ierr = DMConvert(dm, DMPLEX, &plex);CHKERRQ(ierr);
  ierr = DMGetDS(plex, &prob);CHKERRQ(ierr);
  /* J */
  ierr = PetscDSSetConstants(prob, ctx->num_species, constants);CHKERRQ(ierr);
  ierr = PetscDSSetObjective(prob, 0, &f0_jz_sum);CHKERRQ(ierr);
  ierr = DMPlexComputeIntegralFEM(plex,X,tt,NULL);CHKERRQ(ierr);
  J = -ctx->n_0*ctx->v_0*PetscRealPart(tt[0]);
  ierr = getTe_kev(plex, X, NULL, &Te_kev);CHKERRQ(ierr);
  spit_eta = Spitzer(ctx->masses[0],-ctx->charges[0],-ctx->charges[1]/ctx->charges[0],ctx->epsilon0,ctx->lnLam,Te_kev/kev_joul); /* kev --> J (kT) */
  *a_E = ctx->Ez; /* no change */
  if (!rectx->use_spitzer_eta && time > 10) {
    static PetscReal  old_ratio = 1e10;
    ratio = *a_E/J/spit_eta;
    if ((ratio < 1.01 && ratio > 0.99) || (old_ratio <= ratio && ratio < 1.03 && ratio > 0.97)) {
      rectx->use_spitzer_eta = PETSC_TRUE; /* use it next time */
      rectx->j = J;
      rectx->pulse_start = time + 1.; /* start quench now */
    }
    ierr = PetscPrintf(PETSC_COMM_WORLD,"\t\t%D) t=%10.3e ESpitzer E/J vs spitzer ratio=%20.13e J=%10.3e E=%10.3e spit_eta=%10.3e Te_kev=%10.3e %s\n",stepi,time,ratio, J, *a_E, spit_eta, Te_kev, rectx->use_spitzer_eta ? " switch to Spitzer E" : " keep testing");CHKERRQ(ierr);
    old_ratio = ratio;
  } else if (rectx->use_spitzer_eta) {
    /* set E */
    *a_E = spit_eta*J;
    ierr = PetscPrintf(PETSC_COMM_WORLD,"\t%D) use ESpitzer E=%10.3e J=%10.3e Te_kev=%10.3e spit_eta=%10.3e t=%g\n",stepi,*a_E,J,Te_kev,spit_eta,time);CHKERRQ(ierr);
  } else {
    ierr = PetscPrintf(PETSC_COMM_WORLD,"\t\t\t%D) ESpitzer delay E=%10.3e J=%10.3e Te_kev=%10.3e spit_eta=%10.3e t=%g ratio=%20.13e\n",stepi,*a_E,J,Te_kev,spit_eta,time,ctx->Ez/J/spit_eta);CHKERRQ(ierr);
  }
  /* cleanup */
  ierr = DMDestroy(&plex);CHKERRQ(ierr);
  PetscFunctionReturn(0);
}

static PetscErrorCode EInduction(Vec X, Vec X_t, PetscInt step, PetscReal time, LandauCtx *ctx, PetscReal *a_E)
{
  REctx             *rectx = (REctx*)ctx->data;
  PetscErrorCode    ierr;
  PetscInt          ii;
  DM                dm,plex;
  PetscScalar       tt[LANDAU_MAX_SPECIES], constants[LANDAU_MAX_SPECIES];
  PetscReal         dJ_dt;
  PetscDS           prob;

  PetscFunctionBeginUser;
  for (ii=0;ii<ctx->num_species;ii++) constants[ii] = ctx->charges[ii];
  ierr = VecGetDM(X, &dm);CHKERRQ(ierr);
  ierr = DMGetDS(dm, &prob);CHKERRQ(ierr);
  ierr = DMConvert(dm, DMPLEX, &plex);CHKERRQ(ierr);
  /* get d current / dt */
  ierr = PetscDSSetConstants(prob, ctx->num_species, constants);CHKERRQ(ierr);
  ierr = PetscDSSetObjective(prob, 0, &f0_jz_sum);CHKERRQ(ierr);
  if (!X_t) SETERRQ(PETSC_COMM_SELF, PETSC_ERR_PLIB, "X_t");
  ierr = DMPlexComputeIntegralFEM(plex,X_t,tt,NULL);CHKERRQ(ierr);
  dJ_dt = -ctx->n_0*ctx->v_0*PetscRealPart(tt[0])/ctx->t_0;
  /* E induction */
  *a_E = -rectx->L*dJ_dt + rectx->Ez_initial;
  ierr = DMDestroy(&plex);CHKERRQ(ierr);
  PetscFunctionReturn(0);
}

static PetscErrorCode EConstant(Vec X,  Vec X_t, PetscInt step, PetscReal time, LandauCtx *ctx, PetscReal *a_E)
{
  PetscFunctionBeginUser;
  *a_E = ctx->Ez;
  PetscFunctionReturn(0);
}

static PetscErrorCode ENone(Vec X,  Vec X_t, PetscInt step, PetscReal time, LandauCtx *ctx, PetscReal *a_E)
{
  PetscFunctionBeginUser;
  *a_E = 0;
  PetscFunctionReturn(0);
}

/* ------------------------------------------------------------------- */
/*
   FormSource - Evaluates source terms F(t).

   Input Parameters:
.  ts - the TS context
.  time -
.  X_dummmy - input vector
.  dummy - optional user-defined context, as set by SNESSetFunction()

   Output Parameter:
.  F - function vector
 */
static PetscErrorCode FormSource(TS ts,PetscReal ftime,Vec X_dummmy, Vec F,void *dummy)
{
  PetscReal      new_imp_rate;
  LandauCtx      *ctx;
  DM             dm,plex;
  PetscErrorCode ierr;
  REctx          *rectx;

  PetscFunctionBeginUser;
  ierr = TSGetDM(ts,&dm);CHKERRQ(ierr);
  ierr = DMGetApplicationContext(dm, &ctx);CHKERRQ(ierr);
  rectx = (REctx*)ctx->data;
  /* check for impurities */
  ierr = rectx->impuritySrcRate(ftime,&new_imp_rate,ctx);CHKERRQ(ierr);
  if (new_imp_rate != 0) {
    if (new_imp_rate != rectx->current_rate) {
      PetscInt       ii;
      PetscReal      dne_dt,dni_dt,tilda_ns[LANDAU_MAX_SPECIES],temps[LANDAU_MAX_SPECIES];
      PetscDS        prob; /* diagnostics only */
      rectx->current_rate = new_imp_rate;
      ierr = DMConvert(dm, DMPLEX, &plex);CHKERRQ(ierr);
      ierr = DMGetDS(dm, &prob);CHKERRQ(ierr);
      dni_dt = new_imp_rate              /* *ctx->t_0 */; /* fully ionized immediately, no normalize, stay in non-dim */
      dne_dt = new_imp_rate*rectx->Ne_ion/* *ctx->t_0 */;
      ierr = PetscPrintf(PETSC_COMM_SELF, "\tFormSource: have new_imp_rate= %10.3e time= %10.3e de/dt= %10.3e di/dt= %10.3e ***\n",new_imp_rate,ftime,dne_dt,dni_dt);CHKERRQ(ierr);
      for (ii=1;ii<LANDAU_MAX_SPECIES;ii++) tilda_ns[ii] = 0;
      for (ii=1;ii<LANDAU_MAX_SPECIES;ii++)    temps[ii] = 1;
      tilda_ns[0] = dne_dt;        tilda_ns[rectx->imp_idx] = dni_dt;
      temps[0]    = rectx->T_cold;    temps[rectx->imp_idx] = rectx->T_cold;
      /* add it */
      if (!rectx->imp_src) {
        ierr = DMCreateGlobalVector(dm, &rectx->imp_src);CHKERRQ(ierr);
        ierr = PetscObjectSetName((PetscObject)rectx->imp_src, "source");CHKERRQ(ierr);
      }
      ierr = VecZeroEntries(rectx->imp_src);CHKERRQ(ierr);
      ierr = LandauAddMaxwellians(plex,rectx->imp_src,ftime,temps,tilda_ns,ctx);CHKERRQ(ierr);
      /* clean up */
      ierr = DMDestroy(&plex);CHKERRQ(ierr);
      if (0) {
        KSP ksp;
        Vec S;
        ierr = KSPCreate(PETSC_COMM_SELF,&ksp);CHKERRQ(ierr);
        ierr = KSPSetOptionsPrefix(ksp,"mass_");CHKERRQ(ierr); /* stokes */
        ierr = KSPSetOperators(ksp,ctx->M,ctx->M);CHKERRQ(ierr);
        ierr = KSPSetFromOptions(ksp);CHKERRQ(ierr);
        ierr = DMCreateGlobalVector(dm, &S);CHKERRQ(ierr);
        ierr = KSPSolve(ksp,rectx->imp_src,S);CHKERRQ(ierr);
        ierr = VecCopy(S,rectx->imp_src);CHKERRQ(ierr);
        ierr = VecDestroy(&S);CHKERRQ(ierr);
      }
      ierr = VecViewFromOptions(rectx->imp_src,NULL,"-vec_view_sources");CHKERRQ(ierr);
    }
    ierr = VecCopy(rectx->imp_src,F);CHKERRQ(ierr);
  } else {
    if (rectx->current_rate != 0 && rectx->imp_src) {
      ierr = VecZeroEntries(rectx->imp_src);CHKERRQ(ierr);
    }
    rectx->current_rate = 0;
  }
  PetscFunctionReturn(0);
}
PetscErrorCode Monitor(TS ts, PetscInt stepi, PetscReal time, Vec X, void *actx)
{
  LandauCtx         *ctx = (LandauCtx*) actx;   /* user-defined application context */
  REctx             *rectx = (REctx*)ctx->data;
  DM                dm,plex;
  PetscDS           prob;
  TSConvergedReason reason;
  PetscErrorCode    ierr;

  PetscFunctionBeginUser;
  ierr = VecGetDM(X, &dm);CHKERRQ(ierr);
  if (stepi > rectx->plotStep && rectx->plotting) {
    rectx->plotting = PETSC_FALSE; /* was doing diagnostics, now done */
    rectx->plotIdx++;
  }
  /* view */
  ierr = TSGetConvergedReason(ts,&reason);CHKERRQ(ierr);
  if (time/rectx->plotDt >= (PetscReal)rectx->plotIdx || reason) {
    /* print norms */
    ierr = LandauPrintNorms(X, stepi);CHKERRQ(ierr);
    ierr = DMConvert(dm, DMPLEX, &plex);CHKERRQ(ierr);
    ierr = DMGetDS(plex, &prob);CHKERRQ(ierr);
    /* diagnostics */
    ierr = rectx->test(ts,X,plex,stepi,time,reason ? PETSC_TRUE : PETSC_FALSE, ctx,rectx);CHKERRQ(ierr);
    ierr = DMDestroy(&plex);CHKERRQ(ierr);
    /* view */
    ierr = DMSetOutputSequenceNumber(dm, rectx->plotIdx, time*ctx->t_0);CHKERRQ(ierr);
    ierr = VecViewFromOptions(X,NULL,"-vec_view");CHKERRQ(ierr);
    rectx->plotStep = stepi;
    rectx->plotting = PETSC_TRUE;
  }
  /* parallel check */
  if (reason) {
    PetscReal    val,rval;
    PetscMPIInt    rank;
    ierr = MPI_Comm_rank(PETSC_COMM_WORLD, &rank);CHKERRQ(ierr);
    ierr = TSGetSolution(ts, &X);CHKERRQ(ierr);
    ierr = VecNorm(X,NORM_2,&val);CHKERRQ(ierr);
    ierr = MPIU_Allreduce(&val,&rval,1,MPIU_REAL,MPIU_MAX,PETSC_COMM_WORLD);CHKERRQ(ierr);
    if (rval != val) {
      ierr = PetscPrintf(PETSC_COMM_SELF, " ***** [%D] ERROR max |x| = %e, my |x| = %20.13e\n",rank,rval,val);CHKERRQ(ierr);
    } else {
      ierr = PetscPrintf(PETSC_COMM_WORLD, "[%D] parallel consistency check OK\n",rank);CHKERRQ(ierr);
    }
  }
  rectx->idx = 0;
  PetscFunctionReturn(0);
}

PetscErrorCode PreStep(TS ts)
{
  PetscErrorCode ierr;
  LandauCtx      *ctx;
  REctx          *rectx;
  DM             dm;
  PetscInt       stepi;
  PetscReal      time;
  Vec            X;

  PetscFunctionBeginUser;
  /* check seed RE run */
  ierr = TSGetDM(ts,&dm);CHKERRQ(ierr);
  ierr = TSGetTime(ts,&time);CHKERRQ(ierr);
  ierr = TSGetSolution(ts,&X);CHKERRQ(ierr);
  ierr = DMGetApplicationContext(dm, &ctx);CHKERRQ(ierr);
  rectx = (REctx*)ctx->data;
  ierr = TSGetStepNumber(ts, &stepi);CHKERRQ(ierr);
  /* update E */
  ierr = rectx->E(X, NULL, stepi, time, ctx, &ctx->Ez);CHKERRQ(ierr);
  PetscFunctionReturn(0);
}

/* model for source of non-ionized impurities, profile provided by model, in du/dt form in normalized units (tricky because n_0 is normalized with electrons) */
static PetscErrorCode stepSrc(PetscReal time, PetscReal *rho, LandauCtx *ctx)
{
  REctx         *rectx = (REctx*)ctx->data;

  PetscFunctionBeginUser;
  if (time >= rectx->pulse_start) *rho = rectx->pulse_rate;
  else *rho = 0.;
  PetscFunctionReturn(0);
}
static PetscErrorCode zeroSrc(PetscReal time, PetscReal *rho, LandauCtx *ctx)
{
  PetscFunctionBeginUser;
  *rho = 0.;
  PetscFunctionReturn(0);
}
static PetscErrorCode pulseSrc(PetscReal time, PetscReal *rho, LandauCtx *ctx)
{
  REctx *rectx = (REctx*)ctx->data;

  PetscFunctionBeginUser;
  if (time < rectx->pulse_start || time > rectx->pulse_start + 3*rectx->pulse_width) *rho = 0;
  else if (0) {
    double t = time - rectx->pulse_start, start = rectx->pulse_width, stop = 2*rectx->pulse_width, cycle = 3*rectx->pulse_width, steep = 5, xi = 0.75 - (stop - start)/(2* cycle);
    *rho = rectx->pulse_rate * (cycle / (stop - start)) / (1 + PetscExpReal(steep*(PetscSinReal(2*PETSC_PI*((t - start)/cycle + xi)) - PetscSinReal(2*PETSC_PI*xi))));
  } else if (0) {
    double x = 2*(time - rectx->pulse_start)/(3*rectx->pulse_width) - 1;
    if (x==1 || x==-1) *rho = 0;
    else *rho = rectx->pulse_rate * PetscExpReal(-1/(1-x*x));
  } else {
    double x = PetscSinReal((time-rectx->pulse_start)/(3*rectx->pulse_width)*2*PETSC_PI - PETSC_PI/2) + 1; /* 0:2, integrates to 1.0 */
    *rho = rectx->pulse_rate * x / (3*rectx->pulse_width);
  }
  PetscFunctionReturn(0);
}

#undef __FUNCT__
#define __FUNCT__ "ProcessREOptions"
static PetscErrorCode ProcessREOptions(REctx *rectx, const LandauCtx *ctx, DM dm, const char prefix[])
{
  PetscErrorCode    ierr;
  PetscFunctionList plist = NULL, testlist = NULL, elist = NULL;
  char              pname[256],testname[256],ename[256];
  DM                dummy;

  PetscFunctionBeginUser;
  ierr = DMCreate(PETSC_COMM_WORLD,&dummy);CHKERRQ(ierr);
  rectx->Ne_ion = 1;                 /* number of electrons given up by impurity ion */
  rectx->T_cold = .005;              /* kev */
  rectx->ion_potential = 15;         /* ev */
  rectx->L = 2;
  rectx->X_0 = NULL;
  rectx->imp_idx = ctx->num_species - 1; /* default ionized impurity as last one */
  rectx->pulse_start = 1;
  rectx->pulse_width = 1;
  rectx->plotStep = PETSC_MAX_INT;
  rectx->pulse_rate = 1.e-1;
  rectx->current_rate = 0;
  rectx->plotIdx = 0;
  rectx->imp_src = 0;
  rectx->j = 0;
  rectx->plotDt = 1.0;
  rectx->plotting = PETSC_TRUE;
  rectx->use_spitzer_eta = PETSC_FALSE;
  rectx->idx = 0;
  /* Register the available impurity sources */
  ierr = PetscFunctionListAdd(&plist,"step",&stepSrc);CHKERRQ(ierr);
  ierr = PetscFunctionListAdd(&plist,"none",&zeroSrc);CHKERRQ(ierr);
  ierr = PetscFunctionListAdd(&plist,"pulse",&pulseSrc);CHKERRQ(ierr);
  ierr = PetscStrcpy(pname,"none");CHKERRQ(ierr);
  ierr = PetscFunctionListAdd(&testlist,"none",&testNone);CHKERRQ(ierr);
  ierr = PetscFunctionListAdd(&testlist,"spitzer",&testSpitzer);CHKERRQ(ierr);
  ierr = PetscFunctionListAdd(&testlist,"stable",&testStable);CHKERRQ(ierr);
  ierr = PetscStrcpy(testname,"none");CHKERRQ(ierr);
  ierr = PetscFunctionListAdd(&elist,"none",&ENone);CHKERRQ(ierr);
  ierr = PetscFunctionListAdd(&elist,"spitzer",&ESpitzer);CHKERRQ(ierr);
  ierr = PetscFunctionListAdd(&elist,"induction",&EInduction);CHKERRQ(ierr);
  ierr = PetscFunctionListAdd(&elist,"constant",&EConstant);CHKERRQ(ierr);
  ierr = PetscStrcpy(ename,"constant");CHKERRQ(ierr);

  ierr = PetscOptionsBegin(PETSC_COMM_SELF, prefix, "Options for Runaway/seed electron model", "none");CHKERRQ(ierr);
  ierr = PetscOptionsReal("-ex2_plot_dt", "Plotting interval", "xgc_dmplex.c", rectx->plotDt, &rectx->plotDt, NULL);CHKERRQ(ierr);
  if (rectx->plotDt < 0) rectx->plotDt = 1e30;
  if (rectx->plotDt == 0) rectx->plotDt = 1e-30;
  ierr = PetscOptionsFList("-ex2_impurity_source_type","Name of impurity source to run","",plist,pname,pname,sizeof(pname),NULL);CHKERRQ(ierr);
  ierr = PetscOptionsFList("-ex2_test_type","Name of test to run","",testlist,testname,testname,sizeof(testname),NULL);CHKERRQ(ierr);
  ierr = PetscOptionsInt("-ex2_impurity_index", "index of sink for impurities", "none", rectx->imp_idx, &rectx->imp_idx, NULL);CHKERRQ(ierr);
  if ((rectx->imp_idx >= ctx->num_species || rectx->imp_idx < 1) && ctx->num_species > 1) SETERRQ1(PETSC_COMM_WORLD,PETSC_ERR_ARG_WRONG,"index of sink for impurities ions is out of range (%D), must be > 0 && < NS",rectx->imp_idx);
  ierr = PetscOptionsFList("-ex2_e_field_type","Electric field type","",elist,ename,ename,sizeof(ename),NULL);CHKERRQ(ierr);
  rectx->Ne_ion = -ctx->charges[rectx->imp_idx]/ctx->charges[0];
  ierr = PetscOptionsReal("-ex2_t_cold","Temperature of cold electron and ions after ionization in keV","none",rectx->T_cold,&rectx->T_cold, NULL);CHKERRQ(ierr);
  ierr = PetscOptionsReal("-ex2_pulse_start_time","Time at which pulse happens for 'pulse' source","none",rectx->pulse_start,&rectx->pulse_start, NULL);CHKERRQ(ierr);
  ierr = PetscOptionsReal("-ex2_pulse_width_time","Width of pulse 'pulse' source","none",rectx->pulse_width,&rectx->pulse_width, NULL);CHKERRQ(ierr);
  ierr = PetscOptionsReal("-ex2_pulse_rate","Number density of pulse for 'pulse' source","none",rectx->pulse_rate,&rectx->pulse_rate, NULL);CHKERRQ(ierr);
  rectx->T_cold *= 1.16e7; /* convert to Kelvin */
  ierr = PetscOptionsReal("-ex2_ion_potential","Potential to ionize impurity (should be array) in ev","none",rectx->ion_potential,&rectx->ion_potential, NULL);CHKERRQ(ierr);
  ierr = PetscOptionsReal("-ex2_inductance","","none",rectx->L,&rectx->L, NULL);CHKERRQ(ierr);
  ierr = PetscInfo5(dummy, "Num electrons from ions=%g, T_cold=%10.3e, ion potential=%10.3e, E_z=%10.3e v_0=%10.3e\n",rectx->Ne_ion,rectx->T_cold,rectx->ion_potential,ctx->Ez,ctx->v_0);CHKERRQ(ierr);
  ierr = PetscOptionsEnd();CHKERRQ(ierr);
  /* get impurity source rate function */
  ierr = PetscFunctionListFind(plist,pname,&rectx->impuritySrcRate);CHKERRQ(ierr);
  if (!rectx->impuritySrcRate) SETERRQ1(PETSC_COMM_WORLD,PETSC_ERR_ARG_WRONG,"No impurity source function found '%s'",pname);
  ierr = PetscFunctionListFind(testlist,testname,&rectx->test);CHKERRQ(ierr);
  if (!rectx->test) SETERRQ1(PETSC_COMM_WORLD,PETSC_ERR_ARG_WRONG,"No test found '%s'",testname);
  ierr = PetscFunctionListFind(elist,ename,&rectx->E);CHKERRQ(ierr);
  if (!rectx->E) SETERRQ1(PETSC_COMM_WORLD,PETSC_ERR_ARG_WRONG,"No E field function found '%s'",ename);
  ierr = PetscFunctionListDestroy(&plist);CHKERRQ(ierr);
  ierr = PetscFunctionListDestroy(&testlist);CHKERRQ(ierr);
  ierr = PetscFunctionListDestroy(&elist);CHKERRQ(ierr);
  {
    PetscMPIInt    rank;
    ierr = MPI_Comm_rank(PETSC_COMM_WORLD, &rank);CHKERRQ(ierr);
    if (rank) { /* turn off output stuff for duplicate runs */
      ierr = PetscOptionsClearValue(NULL,"-dm_view");CHKERRQ(ierr);
      ierr = PetscOptionsClearValue(NULL,"-vec_view");CHKERRQ(ierr);
      ierr = PetscOptionsClearValue(NULL,"-dm_view_diff");CHKERRQ(ierr);
      ierr = PetscOptionsClearValue(NULL,"-vec_view_diff");CHKERRQ(ierr);
      ierr = PetscOptionsClearValue(NULL,"-dm_view_sources");CHKERRQ(ierr);
      ierr = PetscOptionsClearValue(NULL,"-vec_view_sources");CHKERRQ(ierr);
    }
  }
  /* convert E from Conner-Hastie E_c units to real */
  {
    PetscReal E = ctx->Ez, Tev = ctx->thermal_temps[0]*8.621738e-5, n = ctx->n_0*ctx->n[0];
    CalculateE(Tev, n, ctx->lnLam, ctx->epsilon0, &E);
    ((LandauCtx*)ctx)->Ez *= E;
  }
  ierr = DMDestroy(&dummy);CHKERRQ(ierr);
  PetscFunctionReturn(0);
}

int main(int argc, char **argv)
{
  DM             dm;
  Vec            X;
  PetscErrorCode ierr;
  PetscInt       dim = 2;
  TS             ts;
  Mat            J;
  PetscDS        prob;
  LandauCtx      *ctx;
  REctx          *rectx;

  ierr = PetscInitialize(&argc, &argv, NULL,help);if (ierr) return ierr;
  ierr = PetscOptionsGetInt(NULL,NULL, "-dim", &dim, NULL);CHKERRQ(ierr);
  /* Create a mesh */
  ierr = LandauCreateVelocitySpace(PETSC_COMM_SELF, dim, "", &X, &J, &dm);CHKERRQ(ierr);
  ierr = LandauCreateMassMatrix(dm, NULL);CHKERRQ(ierr);
  ierr = DMGetApplicationContext(dm, &ctx);CHKERRQ(ierr);
  ierr = DMSetUp(dm);CHKERRQ(ierr);
  ierr = DMGetDS(dm, &prob);CHKERRQ(ierr);
  s_quarter3DDomain_notused = ctx->quarter3DDomain; /* ugh */
  /* context */
  ierr = PetscNew(&rectx);CHKERRQ(ierr);
  ctx->data = rectx;
  ierr = ProcessREOptions(rectx,ctx,dm,"");CHKERRQ(ierr);
  ierr = DMSetOutputSequenceNumber(dm, 0, 0.0);CHKERRQ(ierr);
  ierr = DMViewFromOptions(dm,NULL,"-dm_view");CHKERRQ(ierr);
  ierr = DMViewFromOptions(dm,NULL,"-dm_view_sources");CHKERRQ(ierr);
  ierr = DMViewFromOptions(dm,NULL,"-dm_view_diff");CHKERRQ(ierr);
  /* Create timestepping solver context */
  ierr = TSCreate(PETSC_COMM_SELF,&ts);CHKERRQ(ierr);
  ierr = TSSetDM(ts,dm);CHKERRQ(ierr);
  ierr = TSSetIFunction(ts,NULL,LandauIFunction,NULL);CHKERRQ(ierr);
  ierr = TSSetIJacobian(ts,J,J,LandauIJacobian,NULL);CHKERRQ(ierr);
  ierr = TSSetRHSFunction(ts,NULL,FormSource,NULL);CHKERRQ(ierr);
  ierr = TSSetFromOptions(ts);CHKERRQ(ierr);
  ierr = TSSetSolution(ts,X);CHKERRQ(ierr);
  ierr = TSSetApplicationContext(ts, ctx);CHKERRQ(ierr);
  ierr = TSMonitorSet(ts,Monitor,ctx,NULL);CHKERRQ(ierr);
  ierr = TSSetPreStep(ts,PreStep);CHKERRQ(ierr);
  rectx->Ez_initial = ctx->Ez;       /* cache for induction caclulation - applied E field */
  ierr = MatSetOption(J, MAT_IGNORE_ZERO_ENTRIES, PETSC_TRUE);CHKERRQ(ierr);
  { /* warm up an test just LandauIJacobian */
#if defined(PETSC_USE_LOG)
    PetscLogStage stage;
#endif
    Vec           vec;
    PetscRandom   rctx;
    PetscInt      ii;

    ierr = PetscRandomCreate(PETSC_COMM_SELF,&rctx);CHKERRQ(ierr);
    ierr = PetscRandomSetFromOptions(rctx);CHKERRQ(ierr);
    ierr = VecDuplicate(X,&vec);CHKERRQ(ierr);
    /* warm up */
    ierr = VecSetRandom(vec,rctx);CHKERRQ(ierr);
    ierr = PetscLogStageRegister("Warmup", &stage);CHKERRQ(ierr);
    ierr = PetscLogStagePush(stage);CHKERRQ(ierr);
    ierr = LandauIJacobian(ts,0.0,vec,vec,1.0,J,J,ctx);CHKERRQ(ierr);
    ierr = PetscLogStagePop();CHKERRQ(ierr);
    /* LandauIJacobian */
    ierr = PetscLogStageRegister("LandauIJacobian", &stage);CHKERRQ(ierr);
    ierr = PetscLogStagePush(stage);CHKERRQ(ierr);
    for (ii=0;ii<10;ii++){
      ierr = VecSetRandom(vec,rctx);CHKERRQ(ierr);
      ierr = LandauIJacobian(ts,0.0,vec,vec,1.0,J,J,ctx);CHKERRQ(ierr);
    }
    ierr = PetscLogStagePop();CHKERRQ(ierr);
    ierr = VecDestroy(&vec);CHKERRQ(ierr);
    ierr = PetscRandomDestroy(&rctx);CHKERRQ(ierr);
  }
  ierr = VecViewFromOptions(X,NULL,"-vec_view");CHKERRQ(ierr); // inital condition (monitor plots after step)
  /* go */
  ierr = TSSolve(ts,X);CHKERRQ(ierr);
  /* clean up */
  ierr = LandauDestroyVelocitySpace(&dm);CHKERRQ(ierr);
  ierr = TSDestroy(&ts);CHKERRQ(ierr);
  ierr = VecDestroy(&X);CHKERRQ(ierr);
  if (rectx->imp_src) {
    ierr = VecDestroy(&rectx->imp_src);CHKERRQ(ierr);
  }
  ierr = PetscFree(rectx);CHKERRQ(ierr);
  ierr = PetscFinalize();
  return ierr;
}

/*TEST
  test:
    suffix: 0
    requires: p4est !complex double
    args: -dm_landau_Ez 0 -petscspace_degree 2 -petscspace_poly_tensor 1 -dm_landau_type p4est -info :dm,tsadapt -dm_landau_ion_masses 2 -dm_landau_ion_charges 1 -dm_landau_thermal_temps 5,5 -dm_landau_n 2,2 -dm_landau_n_0 5e19 -ts_monitor -snes_rtol 1.e-10 -snes_stol 1.e-14 -snes_monitor -snes_converged_reason -snes_max_it 10 -ts_type arkimex -ts_arkimex_type 1bee -ts_max_snes_failures -1 -ts_rtol 1e-3 -ts_dt 1.e-1 -ts_max_time 1 -ts_adapt_clip .5,1.25 -ts_max_steps 2 -ts_adapt_scale_solve_failed 0.75 -ts_adapt_time_step_increase_delay 5 -pc_type lu -ksp_type preonly -dm_landau_amr_levels_max 9 -dm_landau_domain_radius -.75 -ex2_impurity_source_type pulse -ex2_pulse_start_time 1e-1 -ex2_pulse_width_time 10 -ex2_pulse_rate 1e-2 -ex2_t_cold .05 -ex2_plot_dt 1e-1 -dm_refine 1

TEST*/
