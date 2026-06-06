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

if ! docker image inspect kinginsun/nonmem:7.4.3 >/dev/null 2>&1; then
    echo "Docker image kinginsun/nonmem:7.4.3 not found."
    echo "Pull the pre-built image:"
    echo "  docker pull kinginsun/nonmem:7.4.3"
    exit 12
fi

if [ ! -f license/nonmem.lic ]; then
    echo "Place your license at: ${NMRoot}/license/nonmem.lic"
    exit 13
fi

clean_models_artifacts() {
    find models -maxdepth 1 \( \
        -name 'temp_dir' -o -name 'modelfit_dir*' -o -name 'worker*' -o \
        -name 'bootstrap_dir*' -o -name 'NM_run*' -o -name 'nonmem' \
    \) -exec rm -rf {} + 2>/dev/null || true
}

check_run_ok() {
    local label="$1"
    local lst="$2"
    if [[ -f "$lst" ]] && grep -aqE "OBJECTIVE VALUE|MINIMUM VALUE OF THE OBJECTIVE FUNCTION|#CPUT:|Stop Time:" "$lst" 2>/dev/null; then
        echo "PASS: $label (see $lst)"
        return 0
    fi
    local log
    log="$(find modelfit_dir* -name nmfe_output.txt 2>/dev/null | head -1)"
    if [[ -n "$log" ]] && grep -q "Done with nonmem execution" "$log" 2>/dev/null; then
        echo "PASS: $label (see $log)"
        return 0
    fi
    echo "FAIL: $label — no successful NONMEM output found."
    echo "      Hint: PsN prints F:1 for Finished (not Failed). Check modelfit_dir*/NM_run1/."
    return 1
}

echo "Cleaning stale build artifacts in models/ ..."
clean_models_artifacts

cd models
echo "PsN execute status: S:=Started, F:=Finished (not Failed)"
echo "===============================TEST ONE==============================="
echo "Run test model with execute ......"
echo ""
echo ""
echo ""
echo ""
echo ""
../execute CONTROL5.mod
check_run_ok "execute CONTROL5.mod" "CONTROL5.lst"

echo ""
echo ""
echo ""
echo ""
echo ""
echo "================================TEST TWO==============================="
echo "Run test model with nmfe74 ......"
../util/nmfe74 CONTROL5.mod OUTPUT5
check_run_ok "nmfe74 CONTROL5.mod" "OUTPUT5"
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
check_run_ok "execute MPI" "CONTROL5.lst"
echo ""
echo ""
echo ""
echo ""
echo "================================TEST FOUR==============================="
echo "Run nmfe74 with mpi ......"
cd ..
find models -maxdepth 1 -name 'worker*' -exec rm -rf {} + 2>/dev/null || true
cd models
echo ""
echo ""
echo ""
echo ""
echo ""
../util/nmfe74 CONTROL5.mod OUTPUT5_mpi "-parafile=pirana_auto_mpi.pnm" "[nodes]=4"
check_run_ok "nmfe74 MPI" "OUTPUT5_mpi"
echo ""
echo ""
echo ""
echo ""
cd ..
echo "===============================TEST DONE================================"

echo "(1)仅将命令安装的当前目录，不影响系统已安装的全局NONMEM和PsN"
echo "(2)在Pirana中增加此目录的环境变量，在系统目录之前"