# How to install PETSc

## Install Cygwin


Download and install the Cygwin package from http://www.cygwin.com. Make sure the following Cygwin components are installed:

- python3
- make


Remove Cygwin link.exe: Cygwin link.exe can conflict with Intel ifort compiler. If you are using ifort, run [from Cygwin terminal/bash-shell]:

mv /usr/bin/link.exe /usr/bin/link-cygwin.exe

## Setup Cygwin terminal/bash-shell with Working Compilers


Run: Start -> All Programs -> Intel oneAPI 2021 -> Intel oneAPI Command Prompt for Intel64 for Visual Studio 2019

In this shell, run c:\cygwin64\bin\mintty.exe
In mintty, run /usr/bin/bash --login
Verify that the compilers are useable (by running cl, ifort in this Cygwin terminal/bash-shell)

## Build 

Run Configure

```
cd /cygdrive/c/Development/petsc-3.14.6
```

```
./configure --with-cc='win32fe cl' --with-fc='win32fe ifort' --with-cxx='win32fe cl' \
--with-mpi-include=['/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/include','/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/include/ilp64'] \
--with-mpi-lib=['/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/lib/release/impi.lib','/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/lib/release/impicxx.lib'] \
--with-mipexec=/cygdrive/c/Progra~2/Intel/oneAPI/mpi/latest/bin/mpiexec.exe \
--with-blaslapack-dir=/cygdrive/c/Progra~2/Intel/oneAPI/mkl/latest/lib/intel64 \
--with-debugging=0 -CFLAGS='-O2 -MD' -CXXFLAGS='-O2 -MD'
```

Build with the instructions as told at the end of the configure output

# How to use

- Install meson and oneAPI
- Open `Intel oneAPI command prompt for Intel 64 for Visual Studio 2019`
- Go to source directory
- Execute `meson setup builddir`
- Execute `meson compile -C builddir`
