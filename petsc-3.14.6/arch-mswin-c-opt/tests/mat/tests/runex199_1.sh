#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex199'
testname='runex199_1'
label='mat_tests-ex199_1'
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
args='-f ${DATAFILESPATH}/matrices/arco1'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    if test -z "${DATAFILESPATH}"; then
        petsc_report_tapoutput "" "${label}" "SKIP Requires DATAFILESPATH"
        total=1; skip=1
        petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
        exit
    fi
fi


nsize_in=${nsize:-3}
mat_coloring_type_in=${mat_coloring_type:- jp power natural greedy}
mat_coloring_distance_in=${mat_coloring_distance:- 1 2}


for insize in ${nsize_in}; do
   for imat_coloring_type in ${mat_coloring_type_in}; do
      for imat_coloring_distance in ${mat_coloring_distance_in}; do

         petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -mat_coloring_type ${imat_coloring_type} -mat_coloring_distance ${imat_coloring_distance}" ex199_1.tmp ${testname}.err "${label}+mat_coloring_type-${imat_coloring_type}_mat_coloring_distance-${imat_coloring_distance}" 
         res=$?

         if test $res = 0; then
            petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/mat/tests/output/ex199_1.out ex199_1.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+mat_coloring_type-${imat_coloring_type}_mat_coloring_distance-${imat_coloring_distance} ""
         else
            petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
         fi

      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
