#!/bin/bash
p=${PWD}
p=${p//\//\\\/}
NMRoot=${PWD}
sed 's/NMHOME/'${p}'/g' execute.dat > execute
sed 's/NMHOME/'${p}'/g' vpc.dat > vpc
sed 's/NMHOME/'${p}'/g' bootstrap.dat > bootstrap
sed 's/NMHOME/'${p}'/g' nmfe74.dat > util/nmfe74
sed 's/NMHOME/'${p}'/g' nmshell.dat > nmshell
sudo chmod +x execute
sudo chmod +x vpc
sudo chmod +x bootstrap
sudo chmod +x nmshell
sudo chmod +x util/nmfe74

cd models
echo "===============================TEST ONE==============================="
echo "Run test model with execute ......"
echo ""
echo ""
echo ""
echo ""
echo ""
../execute CONTROL5.mod

echo ""
echo ""
echo ""
echo ""
echo ""
echo "================================TEST TWO==============================="
echo "Run test model with nmfe74 ......"
../util/nmfe74 CONTROL5.mod OUTPUT5
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
../execute -parafile=pirana_auto_mpi.pnm CONTROL5.mod -nodes='4'
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
../util/nmfe74 CONTROL5.mod OUTPUT5 "-parafile=pirana_auto_mpi.pnm" "[nodes]=4"
echo ""
echo ""
echo ""
echo ""
echo ""
cd ..
echo "===============================TEST DONE================================"

echo "(1)仅将命令安装的当前目录，不影响系统已安装的全局NONMEM和PsN"
echo "(2)在Pirana中增加此目录的环境变量，在系统目录之前"