#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex69'
testname='runex69_1'
label='mat_tests-ex69_1'
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
args='-k 6'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_CUDA requirement not met, PETSC_HAVE_CUDA requirement not met, PETSC_HAVE_CUDA requirement not met"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-1 2}
A_mat_type_in=${A_mat_type:-aij aijcusparse}
test_in=${test:-0 1 2}
l_in=${l:-0 5}
use_shell_in=${use_shell:-0 1}


for insize in ${nsize_in}; do
   for iA_mat_type in ${A_mat_type_in}; do
      for itest in ${test_in}; do
         for il in ${l_in}; do
            for iuse_shell in ${use_shell_in}; do

               petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -A_mat_type ${iA_mat_type} -test ${itest} -l ${il} -use_shell ${iuse_shell}" ex69_1.tmp ${testname}.err "${label}+nsize-${insize}A_mat_type-${iA_mat_type}_test-${itest}_l-${il}_use_shell-${iuse_shell}" 
               res=$?

               if test $res = 0; then
                  petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/mat/tests/output/ex69_1.out ex69_1.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+nsize-${insize}A_mat_type-${iA_mat_type}_test-${itest}_l-${il}_use_shell-${iuse_shell} ""
               else
                  petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
               fi

            done
         done
      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
