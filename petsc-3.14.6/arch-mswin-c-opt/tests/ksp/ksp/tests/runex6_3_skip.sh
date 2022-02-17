#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex6'
testname='runex6_3_skip'
label='ksp_ksp_tests-ex6_3_skip'
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
args='-f ${wPETSC_DIR}/share/petsc/datafiles/matrices/spd-real-int32-float64 -pc_type none -ksp_max_it 8 -ksp_error_if_not_converged -ksp_convergence_test skip -ksp_converged_reason -test_residual'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"





nsize_in=${nsize:-1}
ksp_type_in=${ksp_type:-chebyshev cg groppcg pipecg pipecgrr pipelcg pipeprcg cgne nash stcg gltr fcg pipefcg gmres fgmres lgmres dgmres pgmres tcqmr bcgs ibcgs fbcgs fbcgsr bcgsl pipebcgs cgs tfqmr cr pipecr qcg bicg minres lcd gcr cgls richardson}


for insize in ${nsize_in}; do
   for iksp_type in ${ksp_type_in}; do

      petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -ksp_type ${iksp_type}" ex6_3_skip.tmp ${testname}.err "${label}+ksp_type-${iksp_type}" 
      res=$?

      if test $res = 0; then
         petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ksp/ksp/tests/output/ex6_skip.out ex6_3_skip.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+ksp_type-${iksp_type} ""
      else
         petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
      fi

   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 