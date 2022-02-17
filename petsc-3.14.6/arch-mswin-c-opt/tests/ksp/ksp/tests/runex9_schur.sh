#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex9'
testname='runex9_schur'
label='ksp_ksp_tests-ex9_schur'
runfiles=''
wPETSC_DIR='C:/checkouts/modflow/petsc-3.14.6'
petsc_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6'
petsc_arch='arch-mswin-c-opt'
# Must be consistent with gmakefile.test
testlogtapfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_tap.log
testlogerrfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_err.log
config_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/config'
filter='sed -e "s/CONVERGED_RTOL/CONVERGED_ATOL/g"'
filter_output=''
petsc_bindir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/lib/petsc/bin'
DATAFILESPATH=${DATAFILESPATH:-""}
args='-pc_fieldsplit_type schur -pc_fieldsplit_schur_scale 1.0 -ksp_converged_reason -ksp_error_if_not_converged'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"





nsize_in=${nsize:-1}
pc_fieldsplit_diag_use_amat_in=${pc_fieldsplit_diag_use_amat:-0 1}
pc_fieldsplit_diag_use_amat_in=${pc_fieldsplit_diag_use_amat:-0 1}
pc_fieldsplit_schur_fact_type_in=${pc_fieldsplit_schur_fact_type:-diag lower upper full}


for insize in ${nsize_in}; do
   for ipc_fieldsplit_diag_use_amat in ${pc_fieldsplit_diag_use_amat_in}; do
      for ipc_fieldsplit_diag_use_amat in ${pc_fieldsplit_diag_use_amat_in}; do
         for ipc_fieldsplit_schur_fact_type in ${pc_fieldsplit_schur_fact_type_in}; do

            petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -pc_fieldsplit_diag_use_amat ${ipc_fieldsplit_diag_use_amat} -pc_fieldsplit_diag_use_amat ${ipc_fieldsplit_diag_use_amat} -pc_fieldsplit_schur_fact_type ${ipc_fieldsplit_schur_fact_type}" ex9_schur.tmp ${testname}.err "${label}+pc_fieldsplit_diag_use_amat-${ipc_fieldsplit_diag_use_amat}_pc_fieldsplit_diag_use_amat-${ipc_fieldsplit_diag_use_amat}_pc_fieldsplit_schur_fact_type-${ipc_fieldsplit_schur_fact_type}" 
            res=$?

            if test $res = 0; then
               petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ksp/ksp/tests/output/ex9_schur.out ex9_schur.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+pc_fieldsplit_diag_use_amat-${ipc_fieldsplit_diag_use_amat}_pc_fieldsplit_diag_use_amat-${ipc_fieldsplit_diag_use_amat}_pc_fieldsplit_schur_fact_type-${ipc_fieldsplit_schur_fact_type} ""
            else
               petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
            fi

         done
      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
