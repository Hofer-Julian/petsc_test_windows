#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex75'
testname='runex75_2_seq'
label='ksp_ksp_tutorials-ex75_2_seq'
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
args='-nmat 3 -pc_type none -ksp_converged_reason -ksp_type hpddm -ksp_max_it 1000 -ksp_gmres_restart 40 -ksp_rtol 1e-10 -ksp_hpddm_recycle 20 -load_dir ${DATAFILESPATH}/matrices/hpddm/GCRODR'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_HPDDM requirement not met, Requires DATAFILESPATH"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-1}
ksp_hpddm_type_in=${ksp_hpddm_type:-gcrodr bgcrodr}


for insize in ${nsize_in}; do
   for iksp_hpddm_type in ${ksp_hpddm_type_in}; do

      petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -ksp_hpddm_type ${iksp_hpddm_type}" ex75_2_seq.tmp ${testname}.err "${label}+ksp_hpddm_type-${iksp_hpddm_type}" 
      res=$?

      if test $res = 0; then
         petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ksp/ksp/tutorials/output/ex75_2.out ex75_2_seq.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+ksp_hpddm_type-${iksp_hpddm_type} ""
      else
         petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
      fi

   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
