#########################################################
#########################################################
# Build package + compilation procedure for Dock 6.6 
# on Debian Linux 
#
# Date: 2014.12.28
# url: https://github.com/0x1fff/docker-dock6
#
#########################################################
#########################################################

DOCK_ARCHIVE=$1
CONFIGURE_PARAM=$2
MYPWD=`pwd`
DOCK_ROOT=`pwd`"/dock6"
DOCK_VERSION="6.6"
DOCK_CONFIG_TYPE="gnu"
BUILD_DOCKER="YES"

###############################################
# Please do not modify below this line
###############################################

function myfatal {
	if [ "${1}" -ne 0 ] ; then
		echo "${2}" >&2
		exit $1
	fi
}


###############################################
# MAIN
###############################################

if [ $# -ne 1 -a $# -ne 2 ] ; then 
    myfatal 255 "usage: "$0" <docker_file.tar.gz> [config.parameter]" 
fi 

if [ ! -f "${DOCK_ARCHIVE}" -o ! -r "${DOCK_ARCHIVE}" ] ; then
    myfatal 254 "File "$1" is not readable file"
fi

# Get DISTRIB_DESCRIPTION
DISTRIB_DESCRIPTION=`uname -a`
KERNEL_VERSION=`uname -a`
if [ -e /etc/lsb-release ] ; then
	. /etc/lsb-release
elif [ -e /etc/debian_version ] ; then
	DISTRIB_DESCRIPTION="Debian "`cat /etc/debian_version`
fi

echo ">>>    OS version: ${DISTRIB_DESCRIPTION}"
echo ">>>    Linux Kernel version: ${KERNEL_VERSION}"

case "${CONFIGURE_PARAM}" in
	gnu|gnu.parallel|gnu.pbsa|gnu.parallel.pbsa ) DOCK_CONFIG_TYPE="${CONFIGURE_PARAM}";;
	"") ;;
	*) myfatal 253 "Config option ${CONFIGURE_PARAM} not supported" ;;
esac

DOCK_VERSION=`echo ${DOCK_ARCHIVE} | perl -ne  '$_ =~ m/(\d+\.\d+)/; print $1';`
if [ -z "${DOCK_VERSION}" ] ; then
	myfatal 201 "Unable to find Dock version" 
fi

#######################
## Fetch Dependencies
#######################
echo ">>>    Upgrading OS and installing dependencies for Dock ${DOCK_VERSION} ${DOCK_CONFIG_TYPE}"
BUILD_DEPS="build-essential flex gfortran byacc binutils"
BIN_DEPS="libgfortran3 libquadmath0 python python-support perl perl-modules csh"
if [[ "${DOCK_CONFIG_TYPE}" =~ "parallel" ]] ; then
	BUILD_DEPS="${BUILD_DEPS} mpi-default-dev libcr-dev"
	BIN_DEPS="${BIN_DEPS} mpich2"
fi
# Convert dependencies to array
read -a BUILD_DEPS_ARR <<<"${BUILD_DEPS}"
read -a BIN_DEPS_ARR <<<"${BIN_DEPS}"

apt-get update  -qy
myfatal $? "apt-get update failed"
apt-get upgrade -qy
myfatal $? "apt-get upgrade failed"

apt-get install -qy ${BIN_DEPS_ARR[@]} 
myfatal $? "apt-get bin dependencies failed"
apt-get install -qy ${BUILD_DEPS_ARR[@]}
myfatal $? "apt-get compile dependencies failed"

#######################
## Set up system
#######################
echo ">>>    Setting up yacc and g77 in your system"
update-alternatives --config yacc
myfatal $? "update-alternatives yacc failed"
# Set up G77 as gfortran
if [ ! -f /usr/bin/g77 ] ; then 
	echo ">>>    Creating g77 symlink"
	ln -s /usr/bin/gfortran /usr/bin/g77
fi



#######################
## Unpack
#######################
echo ">>>    Unpacking Dock Archive: ${DOCK_ARCHIVE}"
tar -xzf "${DOCK_ARCHIVE}"
myfatal $? "unpacking failed - ${DOCK_ARCHIVE}"


cd "${DOCK_ROOT}/install/"
myfatal $? "Unable to cd to ${DOCK_ROOT}/install/"



#######################
## Patch
#######################
if [[ "${DOCK_CONFIG_TYPE}" =~ "parallel" ]] ; then
	echo ">>>    Patching config - ${DOCK_CONFIG_TYPE}"
	sed -i 's#$(MPICH_HOME)/bin/mpicxx#/usr/bin/mpicxx#g'     "${DOCK_CONFIG_TYPE}"
	sed -i 's#$(MPICH_HOME)/include#/usr/include/openmpi/#g'  "${DOCK_CONFIG_TYPE}"
fi

#######################
## Build
#######################
echo ">>>    Starting build - configure"
./configure "${DOCK_CONFIG_TYPE}"
myfatal $? "./configure ${DOCK_CONFIG_TYPE} failed"
make clean
myfatal $? "./make clean failed"
echo ">>>    Starting build - make"
make 
myfatal $? "./make failed"


cd "${DOCK_ROOT}"
# We are in dock6 diectory
mkdir -p debian/tmp/DEBIAN
myfatal $? "Unable to create Debian package"

cat <<EOF >debian/changelog
dock (${DOCK_VERSION}-1) UNRELEASED; urgency=low

  * Initial release.

 -- Anonymous <anonymous@anonymous.com>  Thu, 18 Nov 2010 17:25:32 +0000
EOF
cat <<EOF >debian/control
Source: dock
Standards-Version: ${DOCK_VERSION}
Maintainer: Anonymous<anonymous@anonymous.com>
Section: non-free/science
Priority: optional
Build-Depends: debhelper (>= 9)
Homepage: http://dock.compbio.ucsf.edu/DOCK_6/index.htm

Package: dock
Architecture: $(dpkg-architecture -qDEB_BUILD_ARCH)
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Dock6 - Molecular docking software.
EOF

mkdir -p debian/tmp/usr/lib/python2.7/
myfatal $? "Unable to create python directory"
mv bin/mol2.py debian/tmp/usr/lib/python2.7/
myfatal $? "Unable to mv mol2"

mkdir -p debian/tmp/usr/bin/
myfatal $? "Unable to create usr/bin/"
mv bin/* debian/tmp/usr/bin/
myfatal $? "Unable to mv files from bin/ to usr/bin/"

# get dependencies
dpkg-shlibdeps debian/tmp/usr/bin/*
myfatal $? "Generating dpkg-shlibdeps failed"

echo "misc:Depends=python (>= 2.2), python-support (>= 0.90.0), perl-base (>= 5.14.0), csh (>=20110502)" >> debian/substvars

dpkg-gencontrol
myfatal $? "Generating dpkg-gencontrol failed"

fakeroot dpkg-deb -b debian/tmp "${MYPWD}/dock-${DOCK_VERSION}.deb"
myfatal $? "Creating *.deb failed"

dpkg -i "${MYPWD}/dock-${DOCK_VERSION}.deb"
myfatal $? "Dock installation failed"

### 
###### Clean up
if [ "${BUILD_DOCKER}" == "YES" ] ; then
	echo ">>>    Deleting downloaded packages and build dependencies"
	cd "${MYPWD}"
	myfatal $? "Error changing direcotry to ${MYPWD}"

	rm -rf "${DOCK_ARCHIVE}" "${DOCK_ROOT}"
	myfatal $? "Removing dock6 failed"

	apt-get remove -y -auto-remove --purge ${BUILD_DEPS_ARR[@]}
	myfatal $? "Removing build time dependencies failed"
	apt-get autoremove -y
	myfatal $? "Auto-Removing build time dependencies failed"
	rm -rf /var/lib/apt/lists/*
	myfatal $? "Removing /var/lib/apt/lists/ failed"
	rm -rf /var/cache/apt/archives/*
	myfatal $? "Removing /var/cache/apt/archives/ failed"
fi

echo "##################################################################"
echo "# Installation completed                                          "
echo "# dock6 software is in PATH directory and package is in /dock6/   "
echo "##################################################################"
