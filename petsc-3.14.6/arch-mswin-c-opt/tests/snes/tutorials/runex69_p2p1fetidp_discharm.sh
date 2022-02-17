#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex69'
testname='runex69_p2p1fetidp_discharm'
label='snes_tutorials-ex69_p2p1fetidp_discharm'
runfiles=''
wPETSC_DIR='C:/checkouts/modflow/petsc-3.14.6'
petsc_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6'
petsc_arch='arch-mswin-c-opt'
# Must be consistent with gmakefile.test
testlogtapfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_tap.log
testlogerrfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_err.log
config_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/config'
filter='grep -v "variant HERMITIAN" | grep -v "SNES iterations" | grep -v "solver iterations" | grep -v "evaluations="'
filter_output=''
petsc_bindir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/lib/petsc/bin'
DATAFILESPATH=${DATAFILESPATH:-""}
args='-petscpartitioner_type simple -dm_plex_separate_marker -dm_refine 2 -vel_petscspace_degree 2 -pres_petscspace_degree 1 -snes_error_if_not_converged -snes_view -ksp_error_if_not_converged -dm_view -dm_mat_type is -ksp_type fetidp -ksp_fetidp_saddlepoint -ksp_fetidp_saddlepoint_flip -fetidp_ksp_type cg -fetidp_ksp_norm_type natural -fetidp_bddc_pc_bddc_detect_disconnected -fetidp_bddc_pc_bddc_symmetric -fetidp_bddc_pc_bddc_vertex_size 3 -fetidp_bddc_pc_bddc_graph_maxcount 2 -fetidp_bddc_pc_bddc_dirichlet_pc_type none -fetidp_bddc_pc_bddc_neumann_pc_type svd -fetidp_bddc_pc_bddc_coarse_redundant_pc_type cholesky -fetidp_pc_fieldsplit_schur_fact_type diag -fetidp_fieldsplit_p_pc_type jacobi -fetidp_fieldsplit_lag_ksp_type preonly -fetidp_fieldsplit_p_ksp_type preonly -fetidp_pc_discrete_harmonic -fetidp_harmonic_pc_type cholesky'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_TRIANGLE requirement not met"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-5}


for insize in ${nsize_in}; do

   petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args} " ex69_p2p1fetidp_discharm.tmp ${testname}.err "${label}" 
   res=$?

   if test $res = 0; then
      petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/snes/tutorials/output/ex69_p2p1fetidp_discharm.out ex69_p2p1fetidp_discharm.tmp" diff-${testname}.out diff-${testname}.out diff-${label} ""
   else
      petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
   fi

done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
