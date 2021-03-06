class Libgphoto2 < Formula
  desc "Gphoto2 digital camera library"
  homepage "http://www.gphoto.org/proj/libgphoto2/"
  url "https://downloads.sourceforge.net/project/gphoto/libgphoto/2.5.23/libgphoto2-2.5.23.tar.bz2"
  sha256 "d8af23364aa40fd8607f7e073df74e7ace05582f4ba13f1724d12d3c97e8852d"

  bottle do
    sha256 "d5e55b07bcb538aed536da66d79c6366a58e0e106b5835846cf5d8bd06aa02b7" => :catalina
    sha256 "b758f4caa384721d7593bec1314dd9e05fa05f69a74e7edd702dc3e9fabb4377" => :mojave
    sha256 "efb624c0e1495dce73b72b24868a5fab80836aa162b37951c2ad04eba093b5c5" => :high_sierra
    sha256 "21dc9f114533994fbeedd7893a8c40b2ec42f2a46bd14d2c40d463e397e9c69b" => :sierra
    sha256 "3dceac74ce0ab8c74a2aa200547fc614f5ded947332e4ad6586651211f1de42a" => :x86_64_linux
  end

  head do
    url "https://github.com/gphoto/libgphoto2.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "gd"
  depends_on "libtool"
  depends_on "libusb-compat"

  def install
    system "autoreconf", "-fvi" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gphoto2/gphoto2-camera.h>
      int main(void) {
        Camera *camera;
        return gp_camera_new(&camera);
      }
    EOS
    system ENV.cc, "test.c",
      *("-I#{include}" unless OS.mac?),
      *("-Wl,-rpath,#{lib}" unless OS.mac?),
      "-L#{lib}", "-lgphoto2", "-o", "test"
    system "./test"
  end
end
