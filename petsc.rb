# coding: utf-8
require 'formula'

class Petsc < Formula
  homepage 'http://www.mcs.anl.gov/petsc/index.html'
  url 'http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-3.4.4.tar.gz'
  sha1 '2f507195a3142eb0599e78a909446175a597480a'
  head 'https://bitbucket.org/petsc/petsc', :using => :git

  option 'without-check', 'Skip build-time tests (not recommended)'

  depends_on :mpi => :cc
  depends_on :fortran
  depends_on :x11 => :optional

  depends_on :mumps => :optional
  depends_on :metis => :optional
  depends_on :parmetis => :optional
  depends_on :scotch => :optional
  depends_on :scalapack => :optional
  depends_on :'suite-sparse' => :optional

  depends_on :hypre => :optional
  depends_on :blacs => :optional
  depends_on :superlu_dist => :optional
  depends_on :ml => :optional
  
  def install
    ENV.deparallelize

    petsc_arch = 'arch-darwin-c-opt'
    args = ["--with-debugging=0", "--with-shared-libraries=1", "--prefix=#{prefix}/#{petsc_arch}"]
    args << "--with-x=0" if build.without? 'x11'
    args << "—-with-mumps-dir=#{prefix}" if build.with? "mumps"
    args << "—-with-metis-dir=#{prefix}" if build.with? "metis"
    args << "—-with-parmetis-dir=#{prefix}" if build.with? "parmetis"
    args << "—-with-scalapack-dir=#{prefix}" if build.with? "scalapack"
    args << "—-with-umfpack-dir=#{prefix}" if build.with? "umfpack"
    args << "—-download-hypre=1" if build.with? "hypre"
    args << "—-download-blacs=1" if build.with? "blacs"
    args << "—-download-superlu_dist=1" if build.with? "superlu_dist"
    args << "—-download-ml=1" if build.with? "ml"
    
    ENV['PETSC_DIR'] = Dir.getwd  # configure fails if those vars are set differently.
    ENV['PETSC_ARCH'] = petsc_arch
    system "./configure", *args
    system "make all"
    system "make test" if build.with? "check"
    system "make install"

    # Link only what we want.
    include.install_symlink Dir["#{prefix}/#{petsc_arch}/include/*h"], "#{prefix}/#{petsc_arch}/include/finclude", "#{prefix}/#{petsc_arch}/include/petsc-private"
    prefix.install_symlink "#{prefix}/#{petsc_arch}/conf"
    lib.install_symlink Dir["#{prefix}/#{petsc_arch}/lib/*.a"], Dir["#{prefix}/#{petsc_arch}/lib/*.dylib"]
    share.install_symlink Dir["#{prefix}/#{petsc_arch}/share/*"]
  end

  def caveats; <<-EOS
    Set PETSC_DIR to #{prefix}
    and PETSC_ARCH to arch-darwin-c-opt.
    Fortran module files are in #{prefix}/arch-darwin-c-opt/include.
    EOS
  end
end
