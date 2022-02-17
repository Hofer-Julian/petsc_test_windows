#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex56'
testname='runex56_attach_mat_nearnullspace-0_bddc_approx_ml'
label='snes_tutorials-ex56_attach_mat_nearnullspace-0_bddc_approx_ml'
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
args='-cells 2,2,1 -max_conv_its 2 -lx 1. -alpha .01 -petscspace_degree 2 -ksp_type cg -ksp_monitor_short -ksp_rtol 1.e-10 -ksp_converged_reason -petscpartitioner_type simple -ex56_dm_mat_type is -matis_localmat_type aij -pc_type bddc -attach_mat_nearnullspace 0 -pc_bddc_switch_static -prefix_push pc_bddc_dirichlet_ -approximate -pc_type ml -mg_levels_ksp_max_it 1 -mg_levels_ksp_type chebyshev -prefix_pop -prefix_push pc_bddc_neumann_ -approximate -pc_type ml -mg_levels_ksp_max_it 1 -mg_levels_ksp_type chebyshev -prefix_pop'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_ML requirement not met"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-4}


for insize in ${nsize_in}; do

   petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args} " ex56_attach_mat_nearnullspace-0_bddc_approx_ml.tmp ${testname}.err "${label}" 
   res=$?

   if test $res = 0; then
      petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/snes/tutorials/output/ex56_attach_mat_nearnullspace-0_bddc_approx_ml.out ex56_attach_mat_nearnullspace-0_bddc_approx_ml.tmp" diff-${testname}.out diff-${testname}.out diff-${label} ""
   else
      petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
   fi

done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
