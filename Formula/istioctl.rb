class Istioctl < Formula
  desc "Istio configuration command-line utility"
  homepage "https://github.com/istio/istio"
  url "https://github.com/istio/istio.git",
      :tag      => "1.4.0",
      :revision => "c4def934e4f8d1feb42725da41ee0078cde8397f"

  bottle do
    cellar :any_skip_relocation
    sha256 "70ef4153506e43a1a08767c1c6ef5c5b99a8eed4e8de0daac1261a1daa91c19b" => :catalina
    sha256 "70ef4153506e43a1a08767c1c6ef5c5b99a8eed4e8de0daac1261a1daa91c19b" => :mojave
    sha256 "70ef4153506e43a1a08767c1c6ef5c5b99a8eed4e8de0daac1261a1daa91c19b" => :high_sierra
    sha256 "95a5230311f77f0a981bd6f4c83e2162e6312318568dd3b1355c376ce8100d96" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["TAG"] = version.to_s
    ENV["ISTIO_VERSION"] = version.to_s

    srcpath = buildpath/"src/istio.io/istio"
    if OS.mac?
      outpath = buildpath/"out/darwin_amd64/release"
    else
      outpath = buildpath/"out/linux_amd64/release"
    end
    srcpath.install buildpath.children

    cd srcpath do
      system "make", "istioctl"
      prefix.install_metafiles
      bin.install outpath/"istioctl"
    end
  end

  test do
    assert_match "Retrieve policies and rules", shell_output("#{bin}/istioctl get -h")
  end
end
