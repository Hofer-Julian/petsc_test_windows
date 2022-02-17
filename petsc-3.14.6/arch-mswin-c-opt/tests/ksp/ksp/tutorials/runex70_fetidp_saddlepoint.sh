#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex70'
testname='runex70_fetidp_saddlepoint'
label='ksp_ksp_tutorials-ex70_fetidp_saddlepoint'
runfiles=''
wPETSC_DIR='C:/checkouts/modflow/petsc-3.14.6'
petsc_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6'
petsc_arch='arch-mswin-c-opt'
# Must be consistent with gmakefile.test
testlogtapfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_tap.log
testlogerrfile=/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests/test_${petsc_arch}_err.log
config_dir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/config'
filter='grep -v atomic'
filter_output='grep -v atomic'
petsc_bindir='/cygdrive/c/checkouts/modflow/petsc-3.14.6/lib/petsc/bin'
DATAFILESPATH=${DATAFILESPATH:-""}
args='-no_view -dm_mat_type is -stokes_ksp_type fetidp -mx 80 -my 80 -stokes_ksp_converged_reason -stokes_ksp_rtol 1.0e-8 -ppcell 2 -nt 4 -randomize_coords -stokes_ksp_error_if_not_converged -stokes_ksp_fetidp_saddlepoint -stokes_fetidp_ksp_type cg -stokes_ksp_norm_type natural -stokes_fetidp_pc_fieldsplit_schur_fact_type diag -stokes_fetidp_fieldsplit_p_pc_type bjacobi -stokes_fetidp_fieldsplit_lag_ksp_type preonly -stokes_fetidp_fieldsplit_p_ksp_type preonly -stokes_ksp_fetidp_pressure_field 2 -stokes_fetidp_pc_fieldsplit_schur_scale -1'
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

   petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args} " ex70_fetidp_saddlepoint.tmp ${testname}.err "${label}" 
   res=$?

   if test $res = 0; then
      petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ksp/ksp/tutorials/output/ex70_fetidp_saddlepoint.out ex70_fetidp_saddlepoint.tmp" diff-${testname}.out diff-${testname}.out diff-${label} ""
   else
      petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
   fi

done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
