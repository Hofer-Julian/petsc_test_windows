#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex70'
testname='runex70_2_par'
label='mat_tests-ex70_2_par'
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
args='-testcircular -testmatmatt 0'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"





nsize_in=${nsize:-2}
M_in=${M:-7 11}
N_in=${N:-12 9}
K_in=${K:-1 3}
local_in=${local:-0 1}


for insize in ${nsize_in}; do
   for iM in ${M_in}; do
      for iN in ${N_in}; do
         for iK in ${K_in}; do
            for ilocal in ${local_in}; do

               petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -M ${iM} -N ${iN} -K ${iK} -local ${ilocal}" ex70_2_par.tmp ${testname}.err "${label}+M-${iM}_N-${iN}_K-${iK}_local-${ilocal}" 
               res=$?

               if test $res = 0; then
                  petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/mat/tests/output/ex70_1.out ex70_2_par.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+M-${iM}_N-${iN}_K-${iK}_local-${ilocal} ""
               else
                  petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
               fi

            done
         done
      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
