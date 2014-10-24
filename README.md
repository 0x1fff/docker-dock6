docker-dock6
============

Docker container for DOCK6 molecular docking software

DOCK addresses the problem of "docking" molecules to each other. In general, "docking" is the identification of the low-energy binding modes of a small molecule, or ligand, within the active site of a macromolecule, or receptor, whose structure is known. A compound that interacts strongly with, or binds, a receptor associated with a disease may inhibit its function and thus act as a drug. Solving the docking problem computationally requires an accurate representation of the molecular energetics as well as an efficient algorithm to search the potential binding modes.

Historically, the DOCK algorithm addressed rigid body docking using a geometric matching algorithm to superimpose the ligand onto a negative image of the binding pocket. Important features that improved the algorithm's ability to find the lowest-energy binding mode, including force-field based scoring, on-the-fly optimization, an improved matching algorithm for rigid body docking and an algorithm for flexible ligand docking, have been added over the years. For more information on past versions of DOCK, click here.

Description is copied from: http://dock.compbio.ucsf.edu/DOCK_6/dock6_manual.htm

Usage
----------

```bash
## Install Docker and clone this repository
curl -s https://get.docker.io/ubuntu/ | sudo sh
git clone https://github.com/0x1fff/docker-dock6.git

# Download from Dock6 sources from official website using your download key and copy it to repository
cp dock.6.6_source.tar.gz docker-dock6

# Edit docker file if necesary
$EDITOR docker-dock6/Dockerfile

# Build docker image
sudo docker build docker-dock6
```

Dockerfile customization
---------------------------

You can select compile target, currently this targets are supported:

| Target              | Description                                                                 |
| :------------------:|:---------------------------------------------------------------------------:|
| gnu                 | gnu compilers and ACML                                                      |
| gnu.parallel        | gnu compilers with parallel processing capability                           |
| gnu.pbsa            | gnu compilers with PB/SA (ZAP library) capability                           |
| gnu.parallel.pbsa   | gnu compilers with parallel processing and PB/SA (ZAP library) capabilities |

````bash
RUN cd ${DOCK6_HOME} && bash ./dock_install.sh dock.6.6_source.tar.gz
````

to 

````bash
RUN cd ${DOCK6_HOME} && bash ./dock_install.sh dock.6.6_source.tar.gz gnu.parallel
````


Building container
---------------------------------

````
Step 0 : FROM ubuntu:14.10
 ---> 6ef6f1a66de1
....
Step 8 : RUN cd ${DOCK6_HOME} && bash ./dock6_install.sh dock.6.6_source.tar.gz
 ---> Running in c8be89a2c844
###############################################
# DOCK 6.6 Install script (gnu) 
###############################################
>>>    OS version: Ubuntu Utopic Unicorn (development branch)
>>>    Upgrading OS and installing dependencies for Dock6 gnu
....
Installation of 
DOCK v6.6
is complete at Fri Oct 24 20:16:46 UTC 2014.

###############################################
#         Installation completed              #
###############################################
 * Switch to dock6 user with: su - dock6       
 * software is in dock6/bin directory          
###############################################
 ---> 8295812c4339
Removing intermediate container c8be89a2c844
Step 9 : RUN chown -R dock6 ${DOCK6_HOME}
 ---> Running in 374364787df5
 ---> 8bf993cb4771
Removing intermediate container 374364787df5
Step 10 : CMD /bin/bash
 ---> Running in 61a81356ef0d
 ---> 3874db2a05c1
Removing intermediate container 61a81356ef0d
Successfully built 3874db2a05c1
```

License:
---------------------

License Apache License Version 2.0, January 2004 (https://tldrlegal.com/ ; http://choosealicense.com/)

