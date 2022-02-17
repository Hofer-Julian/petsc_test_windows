#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex54'
testname='runex54_1'
label='mat_tests-ex54_1'
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
args=''
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"





nsize_in=${nsize:-1 3}
mat_block_size_in=${mat_block_size:-1 3 4 6 8}
ov_in=${ov:-1 3}
mat_size_in=${mat_size:-11 13}
nd_in=${nd:-7}


for insize in ${nsize_in}; do
   for imat_block_size in ${mat_block_size_in}; do
      for iov in ${ov_in}; do
         for imat_size in ${mat_size_in}; do
            for ind in ${nd_in}; do

               petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -mat_block_size ${imat_block_size} -ov ${iov} -mat_size ${imat_size} -nd ${ind}" ex54_1.tmp ${testname}.err "${label}+nsize-${insize}mat_block_size-${imat_block_size}_ov-${iov}_mat_size-${imat_size}_nd-${ind}" 
               res=$?

               if test $res = 0; then
                  petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/mat/tests/output/ex54.out ex54_1.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+nsize-${insize}mat_block_size-${imat_block_size}_ov-${iov}_mat_size-${imat_size}_nd-${ind} ""
               else
                  petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
               fi

            done
         done
      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
