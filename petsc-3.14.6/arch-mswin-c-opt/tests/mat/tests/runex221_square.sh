#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex221'
testname='runex221_square'
label='mat_tests-ex221_square'
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
args='-M 21 -N 21 -loop 4'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"





nsize_in=${nsize:-1 3}
rows_only_in=${rows_only:-0 1}
keep_in=${keep:-0 1}
submat_in=${submat:-0 1}
test_axpy_different_in=${test_axpy_different:-0 1}


for insize in ${nsize_in}; do
   for irows_only in ${rows_only_in}; do
      for ikeep in ${keep_in}; do
         for isubmat in ${submat_in}; do
            for itest_axpy_different in ${test_axpy_different_in}; do

               petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -rows_only ${irows_only} -keep ${ikeep} -submat ${isubmat} -test_axpy_different ${itest_axpy_different}" ex221_square.tmp ${testname}.err "${label}+nsize-${insize}rows_only-${irows_only}_keep-${ikeep}_submat-${isubmat}_test_axpy_different-${itest_axpy_different}" 
               res=$?

               if test $res = 0; then
                  petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/mat/tests/output/ex221_1.out ex221_square.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+nsize-${insize}rows_only-${irows_only}_keep-${ikeep}_submat-${isubmat}_test_axpy_different-${itest_axpy_different} ""
               else
                  petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
               fi

            done
         done
      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
