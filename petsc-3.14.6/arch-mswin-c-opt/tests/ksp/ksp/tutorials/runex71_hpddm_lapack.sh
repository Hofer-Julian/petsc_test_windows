#!/usr/bin/env bash
# This script was created by gmakegentest.py



# PATH for DLLs on windows
PATH="$PATH":"/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/lib"

exec='../ex71'
testname='runex71_hpddm_lapack'
label='ksp_ksp_tutorials-ex71_hpddm_lapack'
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
args='-pde_type Elasticity -cells 12,12 -dim 2 -ksp_converged_reason -pc_type hpddm -pc_hpddm_coarse_correction balanced -pc_hpddm_levels_1_pc_type asm -pc_hpddm_levels_1_pc_asm_overlap 1 -pc_hpddm_levels_1_pc_asm_type basic -pc_hpddm_levels_1_sub_pc_type cholesky -pc_hpddm_levels_1_eps_nev 10 -pc_hpddm_levels_1_st_pc_factor_shift_type INBLOCKS -pc_hpddm_levels_1_eps_type lapack -pc_hpddm_levels_1_eps_smallest_magnitude -pc_hpddm_levels_1_st_type shift'
diff_args=''
timeoutfactor=1

mpiexec=${PETSCMPIEXEC:-"/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec"}
diffexec=${PETSCDIFF:-"${petsc_bindir}/petscdiff"}

. "${config_dir}/petsc_harness.sh"

# The diff flags come from script arguments
diff_exe="${diffexec} ${diff_flags} ${diff_args}"
mpiexec="${mpiexec} ${mpiexec_flags}"



if ! $force; then
    petsc_report_tapoutput "" "${label}" "SKIP PETSC_HAVE_HPDDM requirement not met, PETSC_HAVE_SLEPC requirement not met"
    total=1; skip=1
    petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
    exit
fi


nsize_in=${nsize:-8}
matis_localmat_type_in=${matis_localmat_type:-aij baij sbaij}
pc_hpddm_coarse_mat_type_in=${pc_hpddm_coarse_mat_type:-baij sbaij}


for insize in ${nsize_in}; do
   for imatis_localmat_type in ${matis_localmat_type_in}; do
      for ipc_hpddm_coarse_mat_type in ${pc_hpddm_coarse_mat_type_in}; do

         petsc_testrun "${mpiexec} -n ${insize} ${exec} ${args}  -matis_localmat_type ${imatis_localmat_type} -pc_hpddm_coarse_mat_type ${ipc_hpddm_coarse_mat_type}" ex71_hpddm_lapack.tmp ${testname}.err "${label}+matis_localmat_type-${imatis_localmat_type}_pc_hpddm_coarse_mat_type-${ipc_hpddm_coarse_mat_type}" 
         res=$?

         if test $res = 0; then
            petsc_testrun "${diff_exe} /cygdrive/c/checkouts/modflow/petsc-3.14.6/src/ksp/ksp/tutorials/output/ex71_hpddm.out ex71_hpddm_lapack.tmp" diff-${testname}.out diff-${testname}.out diff-${label}+matis_localmat_type-${imatis_localmat_type}_pc_hpddm_coarse_mat_type-${ipc_hpddm_coarse_mat_type} ""
         else
            petsc_report_tapoutput "" ${label} "SKIP Command failed so no diff"
         fi

      done
   done
done

petsc_testend "/cygdrive/c/checkouts/modflow/petsc-3.14.6/arch-mswin-c-opt/tests" 
