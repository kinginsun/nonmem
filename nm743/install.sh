#!/bin/bash
p=${PWD}
p=${p//\//\\\/}
sed 's/NMHOME/'${p}'/g' execute.dat > execute
sed 's/NMHOME/'${p}'/g' nmfe74.dat > util/nmfe74
sudo chmod +x execute
sudo chmod +x util/nmfe74

# pull nonmem image
#docker pull kinginsun/nonmem:7.4.3

# test nonmem install
NMRoot=${PWD}
modelFolder=${PWD}
d=`date +%s`
docker run --rm --name nonmem${d} --workdir /nonmem/nm743/util -v ${NMRoot}/license:/nonmem/nm743/license -v ${modelFolder}/models:/nonmem/models kinginsun/nonmem:7.4.3 /bin/bash nmfe74 CONTROL5 OUTPUT5
