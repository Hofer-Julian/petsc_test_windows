#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex27'
testname='runex27_6_hdf5_rect_dense'
label='ksp_ksp_tutorials-ex27_6_hdf5_rect_dense'
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
args='-ksp_converged_reason -ksp_monitor_short -ksp_rtol 1e-5 -ksp_max_it 10 -solve_normal 0 -ksp_type lsqr -hdf5 -x0_name x -f ${DATAFILESPATH}/matrices/matlab/small_rect_dense.mat -mat_type dense'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP Requires DATAFILESPATH, PETSC_HAVE_HDF5 requirement not met, Required: define(PETSC_HDF5_HAVE_ZLIB)"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-1 2 4 8}
test_custom_layout_in=${test_custom_layout:-0 1}


for insize in ${nsize_in}; do
   for itest_custom_layout in ${test_custom_layout_in}; do

      petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -test_custom_layout ${itest_custom_layout}" ex27_6_hdf5_rect_dense.tmp ${testname}.err "${label}+nsize-${insize}test_custom_layout-${itest_custom_layout}" 
      res=$?

      if test $res = 0; then
         petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ksp/ksp/tutorials/output/ex27_6_hdf5_rect_dense.out ex27_6_hdf5_rect_dense.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+nsize-${insize}test_custom_layout-${itest_custom_layout} ""
      else
         petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
      fi

   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
