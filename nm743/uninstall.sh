#!/bin/bash
p=${PWD}
p=${p//\//\\\/}
NMRoot=${PWD}
if [ -e 'execute' ];then
  sudo rm execute
fi
if [ -e 'util/nmfe74' ];then
sudo rm util/nmfe74
fi
cd /usr/local/bin
if [ -e 'execute' ];then
  sudo rm execute
fi
if [ -e 'nmfe74' ];then
  sudo rm nmfe74
fi
cd ${NMRoot}
echo "Uninstall success!"