#!/bin/bash
#echo "$@"
NMRoot=/Users/randyz/Documents/nonmem/nm743
modelFolder=${PWD}
d=`date +%s`
docker run --rm --name nonmem${d} --workdir /nonmem/models -v ${NMRoot}/license:/nonmem/nm743/license -v ${modelFolder}:/nonmem/models kinginsun/nonmemmpi2:7.4.3 execute $@
