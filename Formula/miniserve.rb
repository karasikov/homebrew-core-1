class Miniserve < Formula
  desc "High performance static file server"
  homepage "https://github.com/svenstaro/miniserve"
  url "https://github.com/svenstaro/miniserve/archive/v0.5.0.tar.gz"
  sha256 "5b7c91bdf35e1a17ca006efa0354712301886c5c50952a2162401aef77faced0"
  revision 2

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "82eca53aa5ca2e90b82bbce87ab964bae0e83b536ecf164a7f1c39a89571b855" => :catalina
    sha256 "3b2d47cf800219c31be4767036e8ddfc4dc6bf67793a24f3a7bc83710414cc84" => :mojave
    sha256 "076ced27fb5a0dccfcf1c6059675369360685ba2f939fd7fd70b775a33dfa863" => :high_sierra
    sha256 "30fac7268129a9b66f0fcb1dce17f932828dea1582fc3ecd5f26e437a7c321a4" => :x86_64_linux
  end

  # Miniserve requires a known-good Rust nightly release to use.
  resource "rust-nightly" do
    if OS.mac?
      url "https://static.rust-lang.org/dist/2019-08-24/rust-nightly-x86_64-apple-darwin.tar.xz"
      sha256 "104ddea51b758f4962960097e9e0f3cabf2c671ec3148bc745344431bb93605d"
    else
      url "https://static.rust-lang.org/dist/2019-08-24/rust-nightly-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "85d498de8d2683615548cb27e507fbf7f51451a54498b024b2031eb230869f88"
    end
  end

  def install
    resource("rust-nightly").stage do
      system "./install.sh", "--prefix=#{buildpath}/rust-nightly"
      ENV.prepend_path "PATH", "#{buildpath}/rust-nightly/bin"
    end
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    require "socket"

    server = TCPServer.new(0)
    port = server.addr[1]
    server.close

    pid = fork do
      exec "#{bin}/miniserve", "#{bin}/miniserve", "-i", "127.0.0.1", "--port", port.to_s
    end

    sleep 2

    begin
      read = (bin/"miniserve").read
      assert_equal read, shell_output("curl localhost:#{port}")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
