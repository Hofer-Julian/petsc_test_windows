#!/usr/bin/python3
if __name__ == '__main__':
  import sys
  import os
  sys.path.insert(0, os.path.abspath('config'))
  import configure
  configure_options = [
    '--with-blaslapack-dir=/cygdrive/c/Progra~2/Intel/oneAPI/mkl/latest/lib/intel64',
    '--with-cc=win32fe cl',
    '--with-cxx=win32fe cl',
    '--with-debugging=0',
    '--with-fc=win32fe ifort',
    '--with-mipexec=/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec.exe',
    '--with-mpi-include=[/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/include,/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/include/ilp64]',
    '--with-mpi-lib=[/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/lib/release/impi.lib,/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/lib/release/impicxx.lib]',
    '-CFLAGS=-O2 -MD',
    '-CXXFLAGS=-O2 -MD',
    'PETSC_ARCH=arch-mswin-c-opt',
  ]
  configure.petsc_configure(configure_options)
