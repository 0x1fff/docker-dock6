docker-dock6
==============

Docker container for DOCK6 molecular docking software. This Dockerfile build Dock Debian package and install it. 
Script dock_install.sh can be used to create only deb package (some minor tweaking is required).

DOCK addresses the problem of "docking" molecules to each other. In general, "docking" is the identification of the low-energy binding modes of a small molecule, or ligand, within the active site of a macromolecule, or receptor, whose structure is known. A compound that interacts strongly with, or binds, a receptor associated with a disease may inhibit its function and thus act as a drug. Solving the docking problem computationally requires an accurate representation of the molecular energetics as well as an efficient algorithm to search the potential binding modes.

Historically, the DOCK algorithm addressed rigid body docking using a geometric matching algorithm to superimpose the ligand onto a negative image of the binding pocket. Important features that improved the algorithm's ability to find the lowest-energy binding mode, including force-field based scoring, on-the-fly optimization, an improved matching algorithm for rigid body docking and an algorithm for flexible ligand docking, have been added over the years. For more information on past versions of DOCK, click here.

Description is copied from: http://dock.compbio.ucsf.edu/DOCK_6/dock6_manual.htm

Usage
----------

```bash
## Remove standard Ubuntu Docker installation and install most recent Docker
sudo apt-get purge docker.io
curl -s https://get.docker.io/ubuntu/ | sudo sh

## Create enviroment for docker-informix container build
mkdir dock6_build
cd dock6_build
git clone https://github.com/0x1fff/docker-dock6.git

## Download from Dock6 sources from official website using your download key and copy it to repository
cp dock.6.6_source.tar.gz .

## Start HTTP server with Informix image
python -m SimpleHTTPServer 9090 &
PY_HTTP=$!

## Build docker image (Dockerfile may require minor changes)
sudo docker build -t docker-dock6 docker-dock6

## Shutdown HTTP server
kill $PY_HTTP
```


Dockerfile customization
---------------------------

You can select compile target, currently this targets are supported:

| Target              | Description                                                                 |
| :------------------ |:--------------------------------------------------------------------------- |
| gnu                 | gnu compilers and ACML                                                      |
| gnu.parallel        | gnu compilers with parallel processing capability                           |
| gnu.pbsa            | gnu compilers with PB/SA (ZAP library) capability                           |
| gnu.parallel.pbsa   | gnu compilers with parallel processing and PB/SA (ZAP library) capabilities |


Additional links
-------------------------

 * [Dock6 FAQ](http://dock.compbio.ucsf.edu/DOCK_6/faq.htm)
 * [Dock6 Manual](http://dock.compbio.ucsf.edu/DOCK_6/dock6_manual.htm)


License:
---------------------

License Apache License Version 2.0, January 2004 (https://tldrlegal.com/ ; http://choosealicense.com/)

