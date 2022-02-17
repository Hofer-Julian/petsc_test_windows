#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex10'
testname='runex10_2d_lagrange'
label='dm_dt_tests-ex10_2d_lagrange'
runfiles=''
wPETSC_DIR='C:/checkouts/modflow/petsc-3.14.6'
petsc_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6'
petsc_arch='arch-mswin-c-opt'
# Must be consistent with gmakefile.test
testlogtapfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_tap.log
testlogerrfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_err.log
config_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/config'
filter=''
filter_output=''
petsc_bindir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/lib/petsc/bin'
DATAFILESPATH=${DATAFILESPATH:-""}
args='-dim 2 -simplex true -velocity_petscspace_degree 1 -velocity_petscspace_type poly -velocity_petscspace_components 2 -velocity_petscdualspace_type lagrange -divu_petscspace_degree 0 -divu_petscspace_type poly -divu_petscdualspace_lagrange_continuity false -velocity_sum_petscfe_default_quadrature_order 1 -velocity_sum_petscspace_degree 1 -velocity_sum_petscspace_type sum -velocity_sum_petscspace_variables 2 -velocity_sum_petscspace_components 2 -velocity_sum_petscspace_sum_spaces 2 -velocity_sum_petscspace_sum_concatenate true -velocity_sum_petscdualspace_type lagrange -velocity_sum_subspace0_petscspace_type poly -velocity_sum_subspace0_petscspace_degree 1 -velocity_sum_subspace0_petscspace_variables 2 -velocity_sum_subspace0_petscspace_components 1 -velocity_sum_subspace1_petscspace_type poly -velocity_sum_subspace1_petscspace_degree 1 -velocity_sum_subspace1_petscspace_variables 2 -velocity_sum_subspace1_petscspace_components 1 -divu_sum_petscspace_degree 0 -divu_sum_petscspace_type sum -divu_sum_petscspace_variables 2 -divu_sum_petscspace_components 1 -divu_sum_petscspace_sum_spaces 1 -divu_sum_petscspace_sum_concatenate true -divu_sum_petscdualspace_lagrange_continuity false -divu_sum_subspace0_petscspace_type poly -divu_sum_subspace0_petscspace_degree 0 -divu_sum_subspace0_petscspace_variables 2 -divu_sum_subspace0_petscspace_components 1 -dm_refine 0 -snes_error_if_not_converged -ksp_rtol 1e-10 -ksp_error_if_not_converged -pc_type fieldsplit -pc_fieldsplit_type schur -divu_sum_petscdualspace_lagrange_continuity false -pc_fieldsplit_schur_precondition full'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_TRIANGLE requirement not met"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-1}


for insize in ${nsize_in}; do

   petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args} " ex10_2d_lagrange.tmp ${testname}.err "${label}" 
   res=$?

   if test $res = 0; then
      petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/dt/tests/output/ex10_2d_lagrange.out ex10_2d_lagrange.tmp" diff-${testname}.out diff-${testname}.out diff-${label} ""
   else
      petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
   fi

done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
