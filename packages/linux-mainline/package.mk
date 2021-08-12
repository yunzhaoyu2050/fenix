PKG_NAME="linux-mainline"
PKG_VERSION="5.14-rc5"
PKG_VERSION_SHORT="v5.x"
PKG_SHA256="6c491268e3a941bfb5618c19960fd9797d7c5ff81187c0b2440be92c85293601"
PKG_SOURCE_DIR="linux-${PKG_VERSION}"
PKG_SITE="https://cdn.kernel.org/"
#PKG_URL="https://cdn.kernel.org/pub/linux/kernel/${PKG_VERSION_SHORT}/linux-${PKG_VERSION}.tar.xz"
PKG_URL="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-${PKG_VERSION}.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Mainline linux"
PKG_SOURCE_NAME="linux-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {

	export PATH=$KERNEL_COMPILER_PATH:$PATH
#	export ARCH=arm64
#	export CROSS_COMPILE="${CCACHE} ${KERNEL_COMPILER}"
	export INSTALL_MOD_STRIP=1

	[ "$KERNEL_INSTALL_PATH" ] || \
	    KERNEL_INSTALL_PATH="$BUILD/linux-mainline-install"

	[ "$INSTALL_PATH" ] || \
	    INSTALL_PATH="$KERNEL_INSTALL_PATH"/boot

	[ "$INSTALL_MOD_PATH" ] || \
	    INSTALL_MOD_PATH="$KERNEL_INSTALL_PATH"

	[ "$INSTALL_DTBS_PATH" ] || \
	    INSTALL_DTBS_PATH="$KERNEL_INSTALL_PATH"/boot/dtb

	export INSTALL_DTBS_PATH
	export INSTALL_MOD_PATH
	export INSTALL_PATH

	echo "KERNEL_INSTALL_PATH: $KERNEL_INSTALL_PATH"

# KERNEL_MAKE_ARGS=menuconfig make kernel

	case "$KERNEL_MAKE_ARGS" in
	    "")
	    KERNEL_MAKE_ARGS="Image modules dtbs"
	    ;;
	esac

	c=$PKGS_DIR/$PKG_NAME/configs/${KHADAS_BOARD}.config

	case $KERNEL_CONFIG in
	    "")
	    ;;
	    -)
	    c=
	    ;;
	    *.config*)
	    for c in "$KERNEL_CONFIG" "$PKGS_DIR/$PKG_NAME/configs/$KERNEL_CONFIG" ""; do
	    [ -e "$c" ] && break
	    done
	    ;;
	    *)
	    error_msg "KERNEL_CONFIG: $KERNEL_CONFIG is wrong"
	    return 1
	    ;;
	esac

	[ "$c" ] && {
	    diff -q "$c" .config || {
		echo "KERNEL config updated from $c"
		cp "$c" .config
	    }
	}

	[ ! "$BUILD_LINUX_NOOP" ] || return 0

	for k in $KERNEL_MAKE_ARGS; do

	    case $k in
		install)
		mkdir -p $INSTALL_PATH
		;;
	    esac

	    echo "KERNEL: make $k"
	    make -j${NR_JOBS} ARCH=arm64 CROSS_COMPILE="${CCACHE} ${KERNEL_COMPILER}" $k

	done

}

makeinstall_target() {
	:
}
