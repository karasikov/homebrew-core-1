class Valgrind < Formula
  desc "Dynamic analysis tools (memory, debug, profiling)"
  homepage "https://www.valgrind.org/"

  stable do
    url "https://sourceware.org/pub/valgrind/valgrind-3.15.0.tar.bz2"
    mirror "https://dl.bintray.com/homebrew/mirror/valgrind-3.15.0.tar.bz2"
    sha256 "417c7a9da8f60dd05698b3a7bc6002e4ef996f14c13f0ff96679a16873e78ab1"

    depends_on :maximum_macos => :high_sierra if OS.mac?
  end

  bottle do
    sha256 "0dd94804f5b3f55831c458a6824a4b71c156eeca34687c1add0f770f4e95a01f" => :high_sierra
    sha256 "8b4d5060b34d0f2112d96a2d1e7cea3b2f441bb5ce75c71b05e09aaff100fbf3" => :sierra
    sha256 "dfce3c9c8a3170dcc2e3126746e82ce903daef37acbef01152ecb203a63095cc" => :x86_64_linux
  end

  head do
    url "https://sourceware.org/git/valgrind.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  # Valgrind needs vcpreload_core-*-darwin.so to have execute permissions.
  # See #2150 for more information.
  skip_clean "lib/valgrind"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    args << "--enable-only64bit"
    args << "--build=amd64-darwin" if OS.mac?

    system "./autogen.sh" if build.head?

    # Look for headers in the SDK on Xcode-only systems: https://bugs.kde.org/show_bug.cgi?id=295084
    if build.stable? && OS.mac? && !MacOS::CLT.installed?
      inreplace "coregrind/Makefile.in", %r{(\s)(?=/usr/include/mach/)}, '\1'+MacOS.sdk_path.to_s
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    assert_match "usage", shell_output("#{bin}/valgrind --help")
    # Fails without the package libc6-dbg or glibc-debuginfo installed.
    system "#{bin}/valgrind", "ls", "-l" if OS.mac?
  end
end
