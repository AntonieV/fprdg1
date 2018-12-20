#configuration
CONFIG +=  shared qpa no_mocdepend release qt_no_framework
host_build {
    QT_ARCH = x86_64
    QT_TARGET_ARCH = x86_64
} else {
    QT_ARCH = x86_64
    QMAKE_DEFAULT_LIBDIRS = /usr/lib64 /opt/rh/devtoolset-2/root/usr/lib /lib /usr/lib /opt/rh/devtoolset-2/root/usr/lib/gcc/x86_64-redhat-linux/4.8.2 /opt/rh/devtoolset-2/root/usr/lib64 /lib64
    QMAKE_DEFAULT_INCDIRS = /home/jana/Fachprojekt/fprdg1/.snakemake/conda/0d4528bc/include /opt/rh/devtoolset-2/root/usr/include/c++/4.8.2 /opt/rh/devtoolset-2/root/usr/include/c++/4.8.2/x86_64-redhat-linux /opt/rh/devtoolset-2/root/usr/include/c++/4.8.2/backward /opt/rh/devtoolset-2/root/usr/lib/gcc/x86_64-redhat-linux/4.8.2/include /usr/local/include /opt/rh/devtoolset-2/root/usr/include /usr/include
}
QT_CONFIG +=  minimal-config small-config medium-config large-config full-config gtk2 gtkstyle fontconfig evdev xlib xrender xcb-plugin xcb-qt xcb-glx xcb-xlib xcb-sm xkbcommon-qt accessibility-atspi-bridge kms c++11 accessibility opengl shared qpa reduce_exports reduce_relocations clock-gettime clock-monotonic posix_fallocate mremap getaddrinfo ipv6ifname getifaddrs inotify eventfd threadsafe-cloexec system-jpeg system-png png system-freetype harfbuzz system-zlib glib dbus dbus-linked openssl xcb rpath gstreamer-1.0 icu concurrent audio-backend release

#versioning
QT_VERSION = 5.6.2
QT_MAJOR_VERSION = 5
QT_MINOR_VERSION = 6
QT_PATCH_VERSION = 2

#namespaces
QT_LIBINFIX = 
QT_NAMESPACE = 

QT_EDITION = OpenSource

QT_COMPILER_STDCXX = 201103
QT_GCC_MAJOR_VERSION = 4
QT_GCC_MINOR_VERSION = 8
QT_GCC_PATCH_VERSION = 2
