#########################################################
#########################################################
# Compilation procedure for Dock 6.6 on Ubuntu Linux 
#
# Date: 2014.10.19
# 
# Additional docs (where search for solutions):
# http://dock.compbio.ucsf.edu/DOCK_6/faq.htm
# http://mailman.docking.org/pipermail/dock-fans/2009-September/002247.html
# http://dock.compbio.ucsf.edu/DOCK_6/dock6_manual.htm
#########################################################
#########################################################

ARCHIVE_PATH=$1
CONFIGURE_PARAM=$2
OLD_PWD=`pwd`

###############################################
# Please do not modify below this line
###############################################

function myfatal {
	if [ "${1}" -ne 0 ] ; then
		echo "${2}" >&2
		exit $1
	fi
}

if [ $# -ne 1 -a $# -ne 2 ] ; then 
    myfatal 255 "usage: "$0" <docker_file.tar.gz> [config.parameter]" 
fi 

if [ ! -f "${ARCHIVE_PATH}" -o ! -r "${ARCHIVE_PATH}" ] ; then
    myfatal 254 "File "$1" is not readable file"
fi

case "${CONFIGURE_PARAM}" in
	"")CONFIGURE_PARAM=gnu ;;
	gnu|gnu.parallel|gnu.pbsa|gnu.parallel.pbsa ) ;;
	*) myfatal 253 "Config option ${CONFIGURE_PARAM} not supported" ;;
esac

echo "###############################################"
echo "# DOCK 6.6 Install script (${CONFIGURE_PARAM}) "
echo "###############################################"
. /etc/lsb-release
echo ">>>    OS version: "${DISTRIB_DESCRIPTION}
echo ">>>    Upgrading OS and installing dependencies for Dock6 ${CONFIGURE_PARAM}"
apt-get update  -qy
myfatal $? "apt-get update failed"
apt-get upgrade -qy
myfatal $? "apt-get upgrade failed"
apt-get install -qy build-essential flex gfortran byacc
myfatal $? "apt-get dependencies failed"

################## CONFIGURE SYSTEM #####################
###### set gfortran as g77 (no g77 on Ubuntu)
cd /usr/bin/
if [ ! -f g77 ] ; then 
	echo "creating g77 symlink"
	sudo ln -s gfortran g77
else
	echo "g77 existed in this system"
fi

###### Set default YACC parser to byacc
sudo update-alternatives --config yacc
myfatal $? "update-alternatives failed"

######################## BUILD ##########################
###### Unpack:
cd "${OLD_PWD}"
echo ">>>    Uncompress Dock Archive: ${ARCHIVE_PATH}"
tar -xvzf "${ARCHIVE_PATH}"
myfatal $? "unpacking failed - ${ARCHIVE_PATH}"

###### Go to install dir:
cd "dock6/install/"

CONFIG_TYPE=gnu
if [ "${CONFIGURE_PARAM}" =~ "parallel" ] ; then
	CONFIG_TYPE="${CONFIGURE_PARAM}"
	echo "Installing dependencies for ${CONFIGURE_PARAM}"
	apt-get install -qy mpich2 mpi-default-dev libcr-dev
	myfatal $? "apt-get dependencies for ${CONFIG_TYPE} failed"
	sed -i 's#$(MPICH_HOME)/bin/mpicxx#/usr/bin/mpicxx#g'     "${CONFIG_TYPE}"
	sed -i 's#$(MPICH_HOME)/include#/usr/include/openmpi/#g'  "${CONFIG_TYPE}"
fi

###### Compile:
./configure "${CONFIG_TYPE}"
myfatal $? "./configure ${CONFIG_TYPE} failed"
make clean
myfatal $? "./make clean failed"
make 
myfatal $? "./make failed"


###### Clean up
rm -f "${ARCHIVE_PATH}"
myfatal $? "rm ${ARCHIVE_PATH} failed"
rm -rf /var/lib/apt/lists/*
myfatal $? "rm /var/lib/apt/lists/ failed"
rm -rf /var/cache/apt/archives/*
myfatal $? "rm /var/cache/apt/archives/ failed"

cd "${OLD_PWD}"
echo "" >> .bashrc
echo 'export PATH="dock6/bin:${PATH}"' >> .bashrc
echo "###############################################"
echo "#         Installation completed              #"
echo "###############################################"
echo " * Switch to dock6 user with: su - dock6       "
echo " * software is in dock6/bin directory          "
echo "###############################################"
