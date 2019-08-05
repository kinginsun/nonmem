#!/bin/bash
p=${PWD}
p=${p//\//\\\/}
NMRoot=${PWD}
sed 's/NMHOME/'${p}'/g' execute.dat > execute
sed 's/NMHOME/'${p}'/g' bootstrap.dat > bootstrap
sed 's/NMHOME/'${p}'/g' nmfe74.dat > util/nmfe74
sudo chmod +x execute
sudo chmod +x bootstrap
sudo chmod +x util/nmfe74
if [ -e '/usr/local/bin' ];then
  cd /usr/local/bin
  if [ -e 'execute' ];then
  sudo rm execute
  fi
  cd /usr/local/bin
  if [ -e 'execute' ];then
    sudo rm execute
  fi
  if [ -e 'nmfe74' ];then
    sudo rm nmfe74
  fi
  if [ -e 'bootstrap' ];then
    sudo rm bootstrap
  fi
  if [ -e 'nmfe74' ];then
  sudo rm util/nmfe74
  fi
  sudo ln -s ${NMRoot}/bootstrap
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
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo "================================TEST THREE==============================="
  echo "Run execute with mpi ......"
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  execute -parafile=pirana_auto_mpi.pnm CONTROL5.mod -nodes='4'
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo "================================TEST FOUR==============================="
  echo "Run nmfe74 with mpi ......"
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  nmfe74 CONTROL5.mod OUTPUT5 "-parafile=pirana_auto_mpi.pnm" "[nodes]=4"
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  cd ..
  echo "===============================TEST DONE================================"

else
  echo "No /usr/local/bin in your system ..."
fi