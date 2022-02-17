#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex3'
testname='runex3_2'
label='dm_impls_stag_tutorials-ex3_2'
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
args='-ksp_monitor_short -ksp_converged_reason -pc_fieldsplit_schur_fact_type diag -fieldsplit_0_ksp_type preonly -fieldsplit_1_pc_type none -fieldsplit_0_pc_type gamg -fieldsplit_0_mg_levels_ksp_max_it 3 -fieldsplit_1_ksp_type gmres -fieldsplit_1_ksp_max_it 20 -fieldsplit_0_pc_gamg_esteig_ksp_type gmres'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"





nsize_in=${nsize:-4}


for insize in ${nsize_in}; do

   petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args} " ex3_2.tmp ${testname}.err "${label}" 
   res=$?

   if test $res = 0; then
      petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/stag/tutorials/output/ex3_2.out ex3_2.tmp > diff-${testname}-0.out 2> diff-${testname}-0.out || ${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/stag/tutorials/output/ex3_2_alt.out ex3_2.tmp > diff-${testname}-1.out 2> diff-${testname}-1.out || ${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/stag/tutorials/output/ex3_2_alt_2.out ex3_2.tmp > diff-${testname}-2.out 2> diff-${testname}-2.out || ${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/stag/tutorials/output/ex3_2_alt_3.out ex3_2.tmp > diff-${testname}-3.out 2> diff-${testname}-3.out || ${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/stag/tutorials/output/ex3_2_alt_4.out ex3_2.tmp" diff-${testname}.out diff-${testname}.out diff-${label} ""
   else
      petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
   fi

done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
