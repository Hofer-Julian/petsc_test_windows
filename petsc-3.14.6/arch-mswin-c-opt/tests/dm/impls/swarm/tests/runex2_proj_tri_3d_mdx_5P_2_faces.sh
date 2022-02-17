#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex2'
testname='runex2_proj_tri_3d_mdx_5P_2_faces'
label='dm_impls_swarm_tests-ex2_proj_tri_3d_mdx_5P_2_faces'
runfiles=''
wPETSC_DIR='C:/checkouts/modflow/petsc-3.14.6'
petsc_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6'
petsc_arch='arch-mswin-c-opt'
# Must be consistent with gmakefile.test
testlogtapfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_tap.log
testlogerrfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_err.log
config_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/config'
filter='grep -v marker | grep -v atomic | grep -v usage'
filter_output=''
petsc_bindir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/lib/petsc/bin'
DATAFILESPATH=${DATAFILESPATH:-""}
args='-dm_plex_box_dim 3 -dm_plex_box_faces 2,2,2 -particlesPerCell 5 -mesh_perturbation 1.0e-1 -dm_view -sw_view -petscspace_degree 2 -ptof_pc_type lu -ftop_ksp_rtol 1e-15 -ftop_ksp_type lsqr -ftop_pc_type none'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_CTETGEN requirement not met"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-1}
petscfe_default_quadrature_order_in=${petscfe_default_quadrature_order:-2 3}


for insize in ${nsize_in}; do
   for ipetscfe_default_quadrature_order in ${petscfe_default_quadrature_order_in}; do

      petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -petscfe_default_quadrature_order ${ipetscfe_default_quadrature_order}" ex2_proj_tri_3d_mdx_5P_2_faces.tmp ${testname}.err "${label}+petscfe_default_quadrature_order-${ipetscfe_default_quadrature_order}" 
      res=$?

      if test $res = 0; then
         petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/swarm/tests/output/ex2_proj_tri_3d_mdx_5P_2_faces.out ex2_proj_tri_3d_mdx_5P_2_faces.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+petscfe_default_quadrature_order-${ipetscfe_default_quadrature_order} ""
      else
         petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
      fi

   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
