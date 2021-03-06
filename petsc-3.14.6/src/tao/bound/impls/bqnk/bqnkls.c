#include <../src/tao/bound/impls/bqnk/bqnk.h>

/*MC
  TAOBQNKLS - Bounded Quasi-Newton-Krylov Line Search method for nonlinear minimization with
              bound constraints. This method approximates the Hessian-vector product using a
              limited-memory quasi-Newton formula, and iteratively inverts the Hessian with a
              Krylov solver. The quasi-Newton matrix and its settings can be accessed via the
              prefix `-tao_bqnk_`

  Options Database Keys:
+ -tao_bqnk_max_cg_its - maximum number of bounded conjugate-gradient iterations taken in each Newton loop
. -tao_bqnk_init_type - trust radius initialization method ("constant", "direction", "interpolation")
. -tao_bqnk_update_type - trust radius update method ("step", "direction", "interpolation")
- -tao_bqnk_as_type - active-set estimation method ("none", "bertsekas")

  Level: beginner
M*/
PETSC_EXTERN PetscErrorCode TaoCreate_BQNKLS(Tao tao)
{
  TAO_BNK        *bnk;
  PetscErrorCode ierr;

  PetscFunctionBegin;
  ierr = TaoCreate_BQNK(tao);CHKERRQ(ierr);
  tao->ops->solve = TaoSolve_BNLS;
  bnk = (TAO_BNK*)tao->data;
  bnk->update_type = BNK_UPDATE_STEP;
  PetscFunctionReturn(0);
}
