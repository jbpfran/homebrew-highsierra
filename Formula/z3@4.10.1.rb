## https://raw.githubusercontent.com/Homebrew/homebrew-core/5d6ac395090c6635b634feb6e7fa92a5fd4a1886/Formula/z3.rb
# Commit Jul 30, 2022
## Installed with
# HOMEBREW_CC=gcc-12 HOMEBREW_CXX=g++-12 brew install z3@4.10.1
# Error
# /Library/Developer/CommandLineTools/usr/bin/ranlib: file: libz3.a(dll.o) has no symbols
# Undefined symbols for architecture x86_64:
#   "__ZN12rewriter_tplI21pattern_inference_cfgED2Ev", referenced from:
# Undefined symbols for architecture x86_64:
#   "__ZN12rewriter_tplI21pattern_inference_cfgED2Ev", referenced from:
#       __ZN20pattern_inference_rwD1Ev in sat_smt.a(q_solver.o)
#       __ZN20pattern_inference_rwD1Ev in sat_smt.a(q_solver.o)
# ld: symbol(s) not found for architecture x86_64
# ld: symbol(s) not found for architecture x86_64

class Z3AT4101 < Formula
  desc "High-performance theorem prover"
  homepage "https://github.com/Z3Prover/z3"
  url "https://github.com/Z3Prover/z3/archive/z3-4.10.1.tar.gz"
  sha256 "a86071a03983b3512c44c2bf130adbc3320770dc0198805f6f51c43b0946e11a"
  license "MIT"
  head "https://github.com/Z3Prover/z3.git", branch: "develop"

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/z3[._-]v?(\d+(?:\.\d+)+)["' >]}i)
  end

  # Has Python bindings but are supplementary to the main library
  # which does not need Python.
  depends_on "python@3.10" => :build

  on_linux do
    depends_on "gcc" # For C++17
  end

  fails_with gcc: "5"

  def install
    python3 = Formula["python@3.10"].opt_bin/"python3.10"
    system python3, "scripts/mk_make.py",
                     "--prefix=#{prefix}",
                     "--python",
                     "--pypkgdir=#{prefix/Language::Python.site_packages(python3)}",
                     "--staticlib"

    cd "build" do
      system "make"
      system "make", "install"
    end

    system "make", "-C", "contrib/qprofdiff"
    bin.install "contrib/qprofdiff/qprofdiff"

    pkgshare.install "examples"
  end

  test do
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lz3",
           pkgshare/"examples/c/test_capi.c", "-o", testpath/"test"
    system "./test"
  end
end