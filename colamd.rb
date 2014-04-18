require "formula"

class Colamd < Formula
  homepage "http://www.cise.ufl.edu/research/sparse/colamd/"
  url "http://www.cise.ufl.edu/research/sparse/colamd/COLAMD-2.8.0.tar.gz"
  sha1 "007bc46337dd27102fece0d4e81a9bc9db0d0a67"

  depends_on "suite-sparse-config"

  def suite_sparse_config_options
    Tab.for_formula(Formula["suite-sparse-config"]).used_options
  end

  def install
    make_args = ["INSTALL_LIB=#{lib}", "INSTALL_INCLUDE=#{include}"]
    suite_sparse_config_options.each do |opt|
      make_args << opt.to_s
    end

    ln_s Formula["suite-sparse-config"].libexec, "../SuiteSparse_config"
    system "make", "all", *make_args
    system "make", "demos", *make_args
    lib.mkpath
    include.mkpath
    system "make", "install", *make_args
    (share / name / "demo").install Dir["Demo/*[^.o]"]
  end

  test do
    system "#{share}/#{name}/demo/colamd_example > #{share}/#{name}/demo/my_colamd_example.out"
    test1 = %x(diff #{share}/#{name}/demo/my_colamd_example.out #{share}/#{name}/demo/colamd_example.out).empty? ? true : false
    system "#{share}/#{name}/demo/colamd_l_example > #{share}/#{name}/demo/my_colamd_l_example.out"
    test2 = %x(diff #{share}/#{name}/demo/my_colamd_l_example.out #{share}/#{name}/demo/colamd_l_example.out).empty? ? true : false
    test1 and test2
  end
end
