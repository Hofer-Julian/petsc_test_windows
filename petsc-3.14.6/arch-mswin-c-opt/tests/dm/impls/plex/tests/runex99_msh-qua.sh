#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex99'
testname='runex99_msh-qua'
label='dm_impls_plex_tests-ex99_msh-qua'
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
args='-dir ${wPETSC_DIR}/share/petsc/datafiles/meshes -dm_view ::ascii_info_detail -dm_plex_check_all -dm_plex_gmsh_highorder false -dm_plex_gmsh_use_marker true -msh qua'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP Required: define(PETSC_HAVE_POPEN), Required: define(PETSC_GMSH_EXE), Required: define(PETSC_HAVE_POPEN)"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-1}
order_in=${order:-1 2 3 7}
fmt_in=${fmt:-msh22 msh40 msh41}
bin_in=${bin:-0 1}


for insize in ${nsize_in}; do
   for iorder in ${order_in}; do
      for ifmt in ${fmt_in}; do
         for ibin in ${bin_in}; do

            petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -order ${iorder} -fmt ${ifmt} -bin ${ibin}" ex99_msh-qua.tmp ${testname}.err "${label}+order-${iorder}_fmt-${ifmt}_bin-${ibin}" 
            res=$?

            if test $res = 0; then
               petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/dm/impls/plex/tests/output/ex99_msh-qua.out ex99_msh-qua.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+order-${iorder}_fmt-${ifmt}_bin-${ibin} ""
            else
               petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
            fi

         done
      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
