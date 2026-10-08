# Local recovery package when the distribution Quickshell build lags installed Qt.
# Build in an isolated directory; install the result through pacman, never cmake as root.
pkgname=quickshell
pkgver=0.3.1
pkgrel=1.2
pkgdesc='Quickshell rebuilt for the installed Qt release (Siverteh local recovery)'
arch=('x86_64')
url='https://quickshell.org'
license=('LGPL-3.0-only')
_qt_version=$(pacman -Q qt6-base | awk '{print $2}' | sed 's/-[^-]*$//')
depends=("qt6-base=$_qt_version" "qt6-declarative=$_qt_version" "qt6-wayland=$_qt_version"
         qt6-svg cpptrace jemalloc libdrm libglvnd libpipewire libxcb mesa pam polkit wayland)
makedepends=(cmake ninja git cli11 qt6-shadertools spirv-tools vulkan-headers wayland-protocols)
source=('git+https://github.com/quickshell-mirror/quickshell.git#commit=1a4716cde794a59928d9d9fc15f2afc7a95de360')
sha256sums=('SKIP') # Git source is pinned to the exact upstream release commit.

build() {
  cmake -S quickshell -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
    -DINSTALL_QML_PREFIX=lib/qt6/qml -DDISTRIBUTOR='Siverteh local Qt rebuild'
  cmake --build build --parallel 4
}

package() {
  DESTDIR="$pkgdir" cmake --install build
}
