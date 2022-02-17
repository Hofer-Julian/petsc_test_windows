#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex1'
testname='runex1_ref_bl_3_quad'
label='dm_impls_plex_tests-ex1_ref_bl_3_quad'
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
args='-dim 2 -domain_shape box -cell_simplex 0 -domain_box_sizes 5 -dm_view -interpolate -dm_plex_check_all 0 -dm_refine 1 -dm_plex_cell_refiner boundarylayer -ext_layers 3 -final_diagnostics -dm_plex_refine_boundarylayer_splits 4'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"





nsize_in=${nsize:-1}
ext_hfirst_in=${ext_hfirst:-0 1}


for insize in ${nsize_in}; do
   for iext_hfirst in ${ext_hfirst_in}; do

      petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -ext_hfirst ${iext_hfirst}" ex1_ref_bl_3_quad.tmp ${testname}.err "${label}+ext_hfirst-${iext_hfirst}" 
      res=$?

      if test $res = 0; then
         petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/plex/tests/output/ex1_ref_bl_3_quad.out ex1_ref_bl_3_quad.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+ext_hfirst-${iext_hfirst} ""
      else
         petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
      fi

   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
