import config.package
import os

class Configure(config.package.CMakePackage):
  def __init__(self, framework):
    config.package.CMakePackage.__init__(self, framework)
    self.gitcommit        = '3.2.00'
    self.versionname      = 'KOKKOS_KERNELS_VERSION'  # It looks kokkos-kernels does not yet have a macro for version number
    self.download         = ['git://https://github.com/kokkos/kokkos-kernels.git']
    self.includes         = ['KokkosBlas.hpp','KokkosSparse_CrsMatrix.hpp']
    self.liblist          = [['libkokkoskernels.a']]
    self.functions        = ['']
    # I don't know how to make it work since all KK routines are templated and always need Kokkos::View. So I cheat here and use functionCxx from Kokkos.
    self.functionsCxx     = [1,'namespace Kokkos {void initialize(int&,char*[]);}','int one = 1;char* args[1];Kokkos::initialize(one,args);']
    self.cxx              = 1
    self.requirescxx11    = 1
    self.downloadonWindows= 0
    self.hastests         = 1
    self.requiresrpath    = 1
    return

  def __str__(self):
    output  = config.package.Package.__str__(self)
    if hasattr(self,'system'): output += '  Backend: '+self.system+'\n'
    return output

  def setupDependencies(self, framework):
    config.package.CMakePackage.setupDependencies(self, framework)
    self.externalpackagesdir = framework.require('PETSc.options.externalpackagesdir',self)
    self.kokkos              = framework.require('config.packages.kokkos',self)
    self.deps                = [self.kokkos]
    self.cuda                = framework.require('config.packages.cuda',self)
    self.hip                 = framework.require('config.packages.hip',self)
    self.odeps               = [self.cuda,self.hip]
    return

  def versionToStandardForm(self,ver):
    '''Converts from Kokkos kernels 30101 notation to standard notation 3.1.01'''
    return ".".join(map(str,[int(ver)//10000, int(ver)//100%100, int(ver)%100]))

  def toString(self,string):
    string    = self.libraries.toString(string)
    if self.requiresrpath: return string
    newstring = ''
    for i in string.split(' '):
      if i.find('-rpath') == -1:
        newstring = newstring+' '+i
    return newstring.strip()

  def formCMakeConfigureArgs(self):
    args = config.package.CMakePackage.formCMakeConfigureArgs(self)
    KokkosRoot = self.kokkos.installDir
    args.append('-DKokkos_ROOT='+KokkosRoot)
    # By default it installs in lib64, change it to lib
    args.append('-DCMAKE_INSTALL_LIBDIR:STRING=lib')
    if self.cuda.found:
      self.system = 'CUDA'
      args.append('-DCMAKE_CXX_COMPILER='+os.path.join(KokkosRoot,'bin','nvcc_wrapper'))
      # as of version 3.2.00 Cuda 11 is not supported
      # identifier "cusparseXcsrgemmNnz" is undefined
      if self.cuda.version_tuple >= (11,0):
        args.append('-DKokkosKernels_ENABLE_TPL_CUSPARSE=OFF')

    elif self.hip.found:
      self.system = 'HIP'
      self.pushLanguage('HIP')
      petscHipcc = self.getCompiler()
      self.popLanguage()
      self.getExecutable(petscHipcc,getFullPath=1,resultName='systemHipcc')
      if not hasattr(self,'systemHipcc'):
        raise RuntimeError('HIP error: could not find path of hipcc')
      args = self.rmArgsStartsWith(args,'-DCMAKE_CXX_COMPILER=')
      args.append('-DCMAKE_CXX_COMPILER='+self.systemHipcc)
    return args
