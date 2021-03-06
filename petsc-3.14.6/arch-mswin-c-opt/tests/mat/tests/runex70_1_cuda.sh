#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex70'
testname='runex70_1_cuda'
label='mat_tests-ex70_1_cuda'
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



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_CUDA requirement not met"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-1}
local_in=${local:-0 1}
xgpu_in=${xgpu:-0 1}
bgpu_in=${bgpu:-0 1}
A_mat_type_in=${A_mat_type:-seqaijcusparse seqaij}
testshellops_in=${testshellops:-0 1}


for insize in ${nsize_in}; do
   for ilocal in ${local_in}; do
      for ixgpu in ${xgpu_in}; do
         for ibgpu in ${bgpu_in}; do
            for iA_mat_type in ${A_mat_type_in}; do
               for itestshellops in ${testshellops_in}; do

                  petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -local ${ilocal} -xgpu ${ixgpu} -bgpu ${ibgpu} -A_mat_type ${iA_mat_type} -testshellops ${itestshellops}" ex70_1_cuda.tmp ${testname}.err "${label}+local-${ilocal}_xgpu-${ixgpu}_bgpu-${ibgpu}_A_mat_type-${iA_mat_type}_testshellops-${itestshellops}" 
                  res=$?

                  if test $res = 0; then
                     petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/mat/tests/output/ex70_1.out ex70_1_cuda.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+local-${ilocal}_xgpu-${ixgpu}_bgpu-${ibgpu}_A_mat_type-${iA_mat_type}_testshellops-${itestshellops} ""
                  else
                     petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
                  fi

               done
            done
         done
      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
