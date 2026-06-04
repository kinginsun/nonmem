#!/bin/bash
NMRoot=${PWD}
if [ -e 'execute' ];then
  sudo rm execute
fi
if [ -e 'bootstrap' ];then
  sudo rm bootstrap
fi
if [ -e 'vpc' ];then
  sudo rm vpc
fi
if [ -e 'scm' ];then
  sudo rm scm
fi
if [ -e 'util/nmfe76' ];then
  sudo rm util/nmfe76
fi
if [ -e 'util/ddexpand' ];then
  sudo rm util/ddexpand
fi
if [ -e 'nmshell' ];then
  sudo rm nmshell
fi
cd /usr/local/bin
if [ -e 'execute' ];then
  sudo rm execute
fi
if [ -e 'nmfe76' ];then
  sudo rm nmfe76
fi
if [ -e 'bootstrap' ];then
  sudo rm bootstrap
fi
if [ -e 'nmshell' ];then
  sudo rm nmshell
fi
cd ${NMRoot}
echo "Uninstall success!"
