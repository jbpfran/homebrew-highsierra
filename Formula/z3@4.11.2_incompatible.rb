## Installed with
# HOMEBREW_CC=gcc-12 HOMEBREW_CXX=g++-12 brew install z3@4.11.2
# Error
# Undefined symbols for architecture x86_64:
#   "__ZN12rewriter_tplI21pattern_inference_cfgED2Ev", referenced from:
# Undefined symbols for architecture x86_64:
#   "__ZN12rewriter_tplI21pattern_inference_cfgED2Ev", referenced from:
#       __ZN20pattern_inference_rwD1Ev in sat_smt.a(q_solver.o)
#       __ZN20pattern_inference_rwD1Ev in sat_smt.a(q_solver.o)
# ld: symbol(s) not found for architecture x86_64
# ld: symbol(s) not found for architecture x86_64

class Z3AT4112 < Formula
  desc "High-performance theorem prover"
  homepage "https://github.com/Z3Prover/z3"
  url "https://github.com/Z3Prover/z3/archive/z3-4.11.2.tar.gz"
  sha256 "e3a82431b95412408a9c994466fad7252135c8ed3f719c986cd75c8c5f234c7e"
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
    system ENV.cc, pkgshare/"examples/c/test_capi.c",
           "-I#{include}", "-L#{lib}", "-lz3", "-o", testpath/"test"
    system "./test"
  end
end
