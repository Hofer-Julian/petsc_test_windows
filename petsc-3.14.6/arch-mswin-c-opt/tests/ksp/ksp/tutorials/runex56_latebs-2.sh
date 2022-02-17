#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex56'
testname='runex56_latebs-2'
label='ksp_ksp_tutorials-ex56_latebs-2'
runfiles=''
wPETSC_DIR='C:/checkouts/modflow/petsc-3.14.6'
petsc_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6'
petsc_arch='arch-mswin-c-opt'
# Must be consistent with gmakefile.test
testlogtapfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_tap.log
testlogerrfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_err.log
config_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/config'
filter='grep -v variant'
filter_output=''
petsc_bindir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/lib/petsc/bin'
DATAFILESPATH=${DATAFILESPATH:-""}
args='-test_late_bs -ne 9 -alpha 1.e-3 -ksp_type cg -pc_type gamg -pc_gamg_agg_nsmooths 1 -pc_gamg_reuse_interpolation true -two_solves -ksp_converged_reason -ksp_view -use_mat_nearnullspace -pc_gamg_square_graph 1 -mg_levels_ksp_max_it 1 -mg_levels_ksp_type chebyshev -mg_levels_ksp_chebyshev_esteig 0,0.2,0,1.05 -pc_gamg_esteig_ksp_max_it 10 -pc_gamg_asm_use_agg true -mg_levels_sub_pc_type lu -mg_levels_pc_asm_overlap 0 -pc_gamg_threshold -0.01 -pc_gamg_coarse_eq_limit 200 -pc_gamg_process_eq_limit 30 -pc_gamg_repartition false -pc_mg_cycle_type v -pc_gamg_use_parallel_coarse_grid_solver -mg_coarse_pc_type jacobi -mg_coarse_ksp_type cg -ksp_monitor_short -ksp_view'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"





nsize_in=${nsize:-8}


for insize in ${nsize_in}; do

   petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args} " ex56_latebs-2.tmp ${testname}.err "${label}" 
   res=$?

   if test $res = 0; then
      petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ksp/ksp/tutorials/output/ex56_latebs-2.out ex56_latebs-2.tmp" diff-${testname}.out diff-${testname}.out diff-${label} ""
   else
      petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
   fi

done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
