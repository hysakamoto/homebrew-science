require "formula"

class Superlu < Formula
  homepage "http://crd-legacy.lbl.gov/~xiaoye/SuperLU/"
  url "http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_4.3.tar.gz"
  sha1 "d2863610d8c545d250ffd020b8e74dc667d7cbdd"

  # depends_on "cmake" => :build
  depends_on :fortran
  depends_on 'openblas' => :recommended

  def install    
    ENV.deparallelize
    system "cp MAKE_INC/make.mac-x ./make.inc"
    inreplace 'make.inc', '$(HOME)/Codes/SuperLU_4.3', "#{buildpath}"
    inreplace 'make.inc', 'ranlib', 'echo'

    if build.with? 'openblas'
      inreplace "make.inc", 
      "$(SuperLUroot)/lib/libblas.a", 
      "-L#{Formula["openblas"].lib} -lopenblas"
    else
      system "make blaslib"
    end

    system "make"
    
    inreplace 'make.inc', "#{buildpath}", "#{prefix}"
    prefix.install Dir["*"]

  end

  test do
    cd "#{prefix}/TESTING" do
      ENV.deparallelize
      system "make"
      out = `grep passed #{prefix}/TESTING/*.out`
      print out
      ohai "All the test outputs are in #{prefix}/TESTING/*.out. Please check."      
    end
  end

end
