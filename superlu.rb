require "formula"

class Superlu < Formula
  homepage "http://crd-legacy.lbl.gov/~xiaoye/SuperLU/"
  url "http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_4.3.tar.gz"
  sha1 "d2863610d8c545d250ffd020b8e74dc667d7cbdd"

  depends_on :fortran
  depends_on 'openblas' => :optional

  def install
    ENV.deparallelize
    cp "MAKE_INC/make.mac-x", "./make.inc"

    inreplace 'make.inc' do |s|
      s.gsub! "$(HOME)/Codes/SuperLU_4.3", buildpath
      s.gsub! "ranlib", "echo"
      if build.with? 'openblas'
        s.gsub! "$(SuperLUroot)/lib/libblas.a", "-L#{Formula["openblas"].lib} -lopenblas"
      else
        s.gsub! "$(SuperLUroot)/lib/libblas.a", "-framework Accelerate"
      end
    end

    system "make"
    inreplace 'make.inc', buildpath, prefix
    prefix.install Dir["*"]

  end

  test do
    cp_r "#{prefix}/TESTING", testpath
    cp_r "#{prefix}/SRC", testpath
    cp_r "#{prefix}/EXAMPLE", testpath
    cp "#{prefix}/make.inc", testpath
    cd "#{testpath}/TESTING" 
    ENV.deparallelize
    system "make double complex16"
    assert File.exist?("dtest.out") and File.exist?("ztest.out")
    assert (not File.read("dtest.out").include?("fail"))
    assert (not File.read("ztest.out").include?("fail"))
  end

end
