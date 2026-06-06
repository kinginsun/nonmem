#!/bin/bash
p=${PWD}
p=${p//\//\\\/}
NMRoot=${PWD}
sed 's/NMHOME/'${p}'/g' execute.dat > execute
sed 's/NMHOME/'${p}'/g' vpc.dat > vpc
sed 's/NMHOME/'${p}'/g' scm.dat > scm
sed 's/NMHOME/'${p}'/g' bootstrap.dat > bootstrap
sed 's/NMHOME/'${p}'/g' nmfe76.dat > util/nmfe76
sed 's/NMHOME/'${p}'/g' ddexpand.dat > util/ddexpand
sed 's/NMHOME/'${p}'/g' nmshell.dat > nmshell
sudo chmod +x execute
sudo chmod +x vpc
sudo chmod +x scm
sudo chmod +x bootstrap
sudo chmod +x nmshell
sudo chmod +x util/nmfe76
sudo chmod +x util/ddexpand

echo "Checking environments..."
dk=`docker --help`
if [[ $dk =~ docker ]];then
    echo "docker installed"
else
    echo "please install docker"
    exit 11
fi

dk=`xterm -v`
if [[ $dk =~ XTerm ]];then
    echo "xterm installed"
else
    echo "please install xterm (brew install xterm)"
    exit 11
fi

if ! docker image inspect kinginsun/nonmem:7.6.0 >/dev/null 2>&1; then
    echo "Docker image kinginsun/nonmem:7.6.0 not found."
    echo "Pull the pre-built image:"
    echo "  docker pull kinginsun/nonmem:7.6.0"
    exit 12
fi

if [ ! -f license/nonmem.lic ]; then
    echo "Place your license at: ${NMRoot}/license/nonmem.lic"
    exit 13
fi

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
echo "Run test model with nmfe76 ......"
../util/nmfe76 CONTROL5.mod OUTPUT5
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
echo "Run nmfe76 with mpi ......"
echo ""
echo ""
echo ""
echo ""
echo ""
../util/nmfe76 CONTROL5.mod OUTPUT5 "-parafile=pirana_auto_mpi.pnm" "[nodes]=4"
echo ""
echo ""
echo ""
echo ""
echo ""
cd ..
echo "===============================TEST DONE================================"

echo "(1)仅将命令安装的当前目录，不影响系统已安装的全局NONMEM和PsN"
echo "(2)在Pirana中增加此目录的环境变量，在系统目录之前"
