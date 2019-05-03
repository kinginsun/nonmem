#!/bin/bash
p=${PWD}
p=${p//\//\\\/}
NMRoot=${PWD}
sed 's/NMHOME/'${p}'/g' execute.dat > execute
sed 's/NMHOME/'${p}'/g' nmfe74.dat > util/nmfe74
sudo chmod +x execute
sudo chmod +x util/nmfe74
if [ -e '/usr/local/bin' ];then
  cd /usr/local/bin
  sudo rm execute
  sudo rm nmfe74
  sudo ln -s ${NMRoot}/execute
  sudo ln -s ${NMRoot}/util/nmfe74
  cd ${NMRoot}

  cd models
  echo "===============================TEST ONE==============================="
  echo "Run test model with execute ......"
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  execute CONTROL5.mod

  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo "================================TEST TWO==============================="
  echo "Run test model with nmfe74 ......"
  nmfe74 CONTROL5.mod OUTPUT5
  cd ..
  echo "===============================TEST DONE================================"

else
  echo "No /usr/local/bin in your system ..."
fi