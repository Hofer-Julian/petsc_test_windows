project('petsc_tests', 'fortran',
  version : '0.1',
  default_options : ['warning_level=0'])

fc = meson.get_compiler('fortran')
fc_id = fc.get_id()
compile_args = ['/fpp']                # Activate preprocessing                
add_project_arguments(fc.get_supported_arguments(compile_args), language: 'fortran')


mpi_dep = dependency('mpi', language: 'fortran')
petsc_path= meson.project_source_root() / 'petsc-3.14.6'
petsc_compiled = petsc_path / 'arch-mswin-c-opt'
petsc_dep = fc.find_library('libpetsc', dirs: petsc_compiled / 'lib')
dependencies = [mpi_dep, petsc_dep]



petsc_incdir = include_directories([petsc_path / 'include',
                                    petsc_compiled / 'include'])
petsc_src = petsc_path / 'src'
sources_petsc = [petsc_src / 'dm/f90-mod/petscdmdamod.F90',
                 petsc_src / 'dm/f90-mod/petscdmmod.F90',
                 petsc_src / 'dm/f90-mod/petscdmplexmod.F90',
                 petsc_src / 'dm/f90-mod/petscdmswarmmod.F90',
                 petsc_src / 'ksp/f90-mod/petsckspdefmod.F90',
                 petsc_src / 'ksp/f90-mod/petsckspmod.F90',
                 petsc_src / 'ksp/f90-mod/petscpcmod.F90',
                 petsc_src / 'mat/f90-mod/petscmatmod.F90',
                 petsc_src / 'snes/f90-mod/petscsnesmod.F90',
                 petsc_src / 'sys/f90-mod/petscsysmod.F90',
                 petsc_src / 'sys/mpiuni/f90-mod/mpiunimod.F90',
                 petsc_src / 'tao/f90-mod/petsctaomod.F90',
                 petsc_src / 'ts/f90-mod/petsctsmod.F90',
                 petsc_src / 'vec/f90-mod/petscvecmod.F90',]
petsc_modules = static_library('petsc_modules', 
                               sources_petsc,
                               dependencies: dependencies,
                               include_directories: petsc_incdir)
executable('ex2f',
           'ex2f.F90',
	         dependencies: dependencies,
           link_with: petsc_modules,
           include_directories : petsc_incdir,
           install : true)

configure_file(input: petsc_compiled / 'lib' / 'libpetsc.dll', 
               output: 'libpetsc.dll', 
               copy: true)
