#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex3'
testname='runex3_2'
label='ts_tutorials_advection-diffusion-reaction-ex3_2'
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
args='-pc_type mg -da_refine 2 -ts_view -ts_monitor_draw_solution -ts_monitor -ts_max_time .3 -mg_levels_ksp_max_it 3'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_X requirement not met"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-1}


for insize in ${nsize_in}; do

   petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args} " ex3_2.tmp ${testname}.err "${label}" 
   res=$?

   if test $res = 0; then
      petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ts/tutorials/advection-diffusion-reaction/output/ex3_1.out ex3_2.tmp > diff-${testname}-0.out 2> diff-${testname}-0.out || ${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ts/tutorials/advection-diffusion-reaction/output/ex3_1_alt.out ex3_2.tmp > diff-${testname}-1.out 2> diff-${testname}-1.out || ${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ts/tutorials/advection-diffusion-reaction/output/ex3_1_alt_2.out ex3_2.tmp > diff-${testname}-2.out 2> diff-${testname}-2.out || ${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ts/tutorials/advection-diffusion-reaction/output/ex3_1_alt_3.out ex3_2.tmp > diff-${testname}-3.out 2> diff-${testname}-3.out || ${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ts/tutorials/advection-diffusion-reaction/output/ex3_1_alt_4.out ex3_2.tmp > diff-${testname}-4.out 2> diff-${testname}-4.out || ${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ts/tutorials/advection-diffusion-reaction/output/ex3_1_alt_5.out ex3_2.tmp" diff-${testname}.out diff-${testname}.out diff-${label} ""
   else
      petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
   fi

done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
