class GitDelta < Formula
  desc "Syntax-highlighting pager for git"
  homepage "https://github.com/dandavison/delta"
  url "https://github.com/dandavison/delta/archive/0.0.14.tar.gz"
  sha256 "777b90bb20c89b63eb158d238dfb38914c3bc4617d65f8a0e465227f9c6884f9"
  head "https://github.com/dandavison/delta.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "84e58fc97ad0057fefb99d0a54dd55b144036983e1e8c0288c6db81f283698cc" => :catalina
    sha256 "85d6b34b4896986a1922ccefbae41819f50b5d7d1003d5a74559452af6c4324c" => :mojave
    sha256 "b88d314815bc4701d835a60c15e50d9b0ff91c48bcec13f5297228cfa15bbeba" => :high_sierra
    sha256 "1e0cc8c31c9d8d32f40b49005afa8008f2f2581b07cae2b6c9945c8b80d0cd9b" => :x86_64_linux
  end

  depends_on "rust" => :build
  depends_on "llvm" => :build unless OS.mac?

  conflicts_with "delta", :because => "both install a `delta` binary"

  def install
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    assert_match "delta #{version}", `#{bin}/delta --version`.chomp
  end
end
