#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex1'
testname='runex1_part_parmetis_0'
label='dm_impls_plex_tests-ex1_part_parmetis_0'
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
args='-dim 2 -cell_simplex 0 -dm_refine 1 -interpolate 1 -petscpartitioner_type parmetis -dm_view -petscpartitioner_view -test_redistribute -dm_pre_redist_view ::load_balance -dm_post_redist_view ::load_balance -petscpartitioner_view_graph'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_PARMETIS requirement not met"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-2}
dm_plex_csr_via_mat_in=${dm_plex_csr_via_mat:-0 1}


for insize in ${nsize_in}; do
   for idm_plex_csr_via_mat in ${dm_plex_csr_via_mat_in}; do

      petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -dm_plex_csr_via_mat ${idm_plex_csr_via_mat}" ex1_part_parmetis_0.tmp ${testname}.err "${label}+dm_plex_csr_via_mat-${idm_plex_csr_via_mat}" 
      res=$?

      if test $res = 0; then
         petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/plex/tests/output/ex1_part_parmetis_0.out ex1_part_parmetis_0.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+dm_plex_csr_via_mat-${idm_plex_csr_via_mat} ""
      else
         petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
      fi

   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
