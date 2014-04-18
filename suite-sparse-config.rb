require 'formula'

class SuiteSparseConfig < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://www.cise.ufl.edu/research/sparse/SuiteSparse_config/SuiteSparse_config-4.2.1.tar.gz'
  sha1 '1d6f70ec7ecdb7b60e6a76c59f1f98fb94e7e4d3'

  depends_on "tbb" => :recommended
  depends_on "openblas" => :optional
  depends_on "metis4" => :optional

  def install
    # Switch to the Mac base config, per SuiteSparse README.txt
    system "mv SuiteSparse_config.mk SuiteSparse_config_orig.mk"
    system "mv SuiteSparse_config_Mac.mk SuiteSparse_config.mk"

    make_args = ["INSTALL_LIB=#{libexec}", "INSTALL_INCLUDE=#{libexec}"]
    make_args << "BLAS=" + ((build.with? 'openblas') ? "-L#{Formula['openblas'].lib} -lopenblas" : "-framework Accelerate")
    make_args << "LAPACK=$(BLAS)"
    make_args += ["SPQR_CONFIG=-DHAVE_TBB", "TBB=-L#{Formula['tbb'].lib} -ltbb"] if build.with? "tbb"
    make_args += ["METIS_PATH=", "METIS=-L#{Formula['metis'].lib} -lmetis"] if build.with? "metis4"

    system "make", "all", *make_args

    libexec.mkpath
    lib.mkpath
    include.mkpath
    system "make", "install", *make_args

    libexec.install "SuiteSparse_config.mk"
    include.install_symlink libexec / "SuiteSparse_config.h"
    lib.install_symlink libexec / "libsuitesparseconfig.a"
  end
end

