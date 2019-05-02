#!/bin/bash
p=${PWD}
p="${p//\//\/}"
sed 's/NMHOME/'${p}'/g' execute.dat > execute
sed 's/NMHOME/'${p}'/g' nmfe74.dat > util/nmfe74
sudo chmod +x execute
sudo chmod +x util/nmfe74
