#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex18'
testname='runex18_4_tet_test_orient'
label='dm_impls_plex_tests-ex18_4_tet_test_orient'
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
args='-dim 3 -distribute 0 -dm_plex_check_all'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"





nsize_in=${nsize:-2}
rotate_interface_0_in=${rotate_interface_0:-0 1 2 11 12 13}
rotate_interface_1_in=${rotate_interface_1:-0 1 2 11 12 13}


for insize in ${nsize_in}; do
   for irotate_interface_0 in ${rotate_interface_0_in}; do
      for irotate_interface_1 in ${rotate_interface_1_in}; do

         petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -rotate_interface_0 ${irotate_interface_0} -rotate_interface_1 ${irotate_interface_1}" ex18_4_tet_test_orient.tmp ${testname}.err "${label}+rotate_interface_0-${irotate_interface_0}_rotate_interface_1-${irotate_interface_1}" 
         res=$?

         if test $res = 0; then
            petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/plex/tests/output/ex18_4_tet_test_orient.out ex18_4_tet_test_orient.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+rotate_interface_0-${irotate_interface_0}_rotate_interface_1-${irotate_interface_1} ""
         else
            petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
         fi

      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
