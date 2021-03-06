class Zola < Formula
  desc "Fast static site generator in a single binary with everything built-in"
  homepage "https://www.getzola.org/"
  url "https://github.com/getzola/zola/archive/v0.9.0.tar.gz"
  sha256 "8d226ec764f2bc06de8e49e2e22ccf37811bc478bbcaa83c2c841b222ef4fc4e"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "2dfac53b9f826f22f9ffae18c8799b70ee60c82f05e4b8ed68cd8027a59dbc74" => :catalina
    sha256 "d4410cc94d0f7d2538118a72c81612db8894dded17b8919a8613042eb1154884" => :mojave
    sha256 "598fc17bbf51800f18671664acee37ecff19ab25f7ea89dd46366ba200f232e1" => :high_sierra
    sha256 "99a5d1770aa5876b13eeddd6ef75431ebec09926749f2c947518bcf8af9e17b7" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build
  depends_on "openssl@1.1" unless OS.mac?

  def install
    ENV["OPENSSL_DIR"] = Formula["openssl@1.1"].opt_prefix unless OS.mac?
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."

    bash_completion.install "completions/zola.bash"
    zsh_completion.install "completions/_zola"
    fish_completion.install "completions/zola.fish"
  end

  test do
    system "yes '' | #{bin}/zola init mysite"
    (testpath/"mysite/content/blog/index.md").write <<~EOS
      +++
      +++

      Hi I'm Homebrew.
    EOS
    (testpath/"mysite/templates/page.html").write <<~EOS
      {{ page.content | safe }}
    EOS

    cd testpath/"mysite" do
      system bin/"zola", "build"
    end

    assert_equal "<p>Hi I'm Homebrew.</p>",
      (testpath/"mysite/public/blog/index.html").read.strip
  end
end
