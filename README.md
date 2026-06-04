## 说明（本镜像仅用于个人研究使用）

- 此image基于ubuntu 16.04构建，整合了nonmem7.4.3和PsN4.8.1; 基于ubuntu 18.04 整合了nonmem7.5.0和PsN5.2.6; 基于ubuntu 22.04 整合了nonmem7.6.0和PsN5.2.6
- 目前只做了nmfe74/nmfe75/nmfe76和execute的映射，可以在host主机直接调用；其他PsN命令可以类似的写个shell脚本
- 用户自己的license替换license目录中的nonmem.lic

## 所需要的软件与环境：[安装方法](https://github.com/kinginsun/nonmem/blob/master/how%20to%20install%20nonmem.pptx)

- docker（必须）
- git（必须）
- Pirana mac版（可选）
- XQuatz (不安装pirana可以不需要)

## 不同版本镜像的使用方法

本项目为每个 NONMEM 大版本提供**主机目录**（`nm743` / `nm750` / `nm760`）和**Docker 镜像**。主机脚本通过 `docker run` 把当前模型目录挂载进容器，把 `license/nonmem.lic` 挂载为容器内 license，在**模型所在目录**读写结果。

### 版本一览

| NONMEM | 主机目录 | 推荐镜像标签 | Dockerfile | 基础系统 | PsN | nmfe 命令 |
|--------|----------|--------------|------------|----------|-----|-----------|
| 7.4.3 | `nm743/` | `kinginsun/nonmemmpi2:7.4.3` | `Dockerfile.mpi2` | Ubuntu 16.04 | 4.8.1 | `nmfe74` |
| 7.5.0 | `nm750/` | `kinginsun/nonmemmpi2:7.5.0` | `Dockerfile.7.5.0` | Ubuntu 18.04 | 5.2.6 | `nmfe75` |
| 7.6.0 | `nm760/` | `kinginsun/nonmemmpi2:7.6.0` | `Dockerfile.7.6.0` | Ubuntu 22.04 | 5.2.6 | `nmfe76` |

7.4.3 另有不含 MPI 的镜像 `kinginsun/nonmem:7.4.3`（`Dockerfile`），以及从官网 zip 在线安装的 `NONMEM_7.4.3.Dockerfile`（`kinginsun/dnonmem:7.4.3`）。日常与 Pirana 配合请优先用 **mpi2** 那一列。

### 通用流程（三个版本相同）

在**仓库根目录**操作：

```bash
git clone https://github.com/kinginsun/nonmem.git
cd nonmem
```

1. **准备 `install/` 目录**（不提交 git，需自行从 ICON 获取安装包并解压）：

   | 版本 | `install/` 下需要的目录 |
   |------|-------------------------|
   | 7.4.3 | `nm743CD/`、`PsN-Source01/`（mpi2 用）或 `PsN-Source/`（无 mpi 的 Dockerfile） |
   | 7.5.0 | `nm750CD/`、`PsN-Source/` |
   | 7.6.0 | `nm760CD/`、`PsN-Source/`（见 `install/README.7.6.0.md`） |

2. **构建镜像**（见下节各版本命令）。

3. **配置 license 并生成主机命令**：

   ```bash
   cd nm743   # 或 nm750 / nm760
   cp /path/to/your/nonmem.lic license/nonmem.lic
   ./install.sh
   ```

   `install.sh` 会检查 docker、xterm，根据 `*.dat` 生成 `execute`、`util/nmfeXX` 等可执行脚本，并可用 `models/` 下示例跑测试。

4. **在模型目录运行**（先 `cd` 到 `.mod` 所在目录）：

   ```bash
   /path/to/nonmem/nm750/execute CONTROL5.mod
   /path/to/nonmem/nm750/util/nmfe75 CONTROL5.mod OUTPUT5
   ```

   可选：将 `execute` 或 `util/nmfe75` 链到 `/usr/local/bin` 便于全局调用。

各版本在 `install.sh` 成功后生成的命令：

| 命令 | 7.4.3 (`nm743`) | 7.5.0 (`nm750`) | 7.6.0 (`nm760`) |
|------|-----------------|-----------------|-----------------|
| `execute` | ✓ | ✓ | ✓ |
| `util/nmfeXX` | `nmfe74` | `nmfe75` | `nmfe76` |
| `vpc` / `scm` / `bootstrap` | vpc、bootstrap | 全部 | 全部 |
| `util/ddexpand` | — | ✓ | ✓ |
| `nmshell` | ✓ | ✓ | ✓ |

### NONMEM 7.4.3（`nm743`）

**构建镜像**（在仓库根目录）：

```bash
# 推荐：MPI + PsN（与 nm743/install.sh 一致）
docker build -f Dockerfile.mpi2 -t kinginsun/nonmemmpi2:7.4.3 .

# 仅 NONMEM，无 MPI
docker build -t kinginsun/nonmem:7.4.3 .

# 从官网 zip 下载安装（需 --build-arg NONMEMZIPPASS=...）
docker build -f NONMEM_7.4.3.Dockerfile -t kinginsun/dnonmem:7.4.3 .
```

**主机使用**：

```bash
cd nm743
cp /path/to/nonmem.lic license/nonmem.lic
./install.sh

cd models
../execute CONTROL5.mod
../util/nmfe74 CONTROL5.mod OUTPUT5
../execute -parafile=pirana_auto_mpi.pnm CONTROL5.mod -nodes=4
```

### NONMEM 7.5.0（`nm750`）

**构建镜像**：

```bash
docker build -f Dockerfile.7.5.0 -t kinginsun/nonmemmpi2:7.5.0 .
```

**主机使用**：

```bash
cd nm750
cp /path/to/nonmem.lic license/nonmem.lic
./install.sh

cd models
../execute CONTROL5.mod
../util/nmfe75 CONTROL5.mod OUTPUT5
../vpc ...    # 其他 PsN 命令同理
```

### NONMEM 7.6.0（`nm760`）

**构建前**：将 7.6.0 CD 解压为 `install/nm760CD`（含 `SETUP76`），说明见 `install/README.7.6.0.md`。

**构建镜像**：

```bash
docker build -f Dockerfile.7.6.0 -t kinginsun/nonmemmpi2:7.6.0 .
```

镜像采用多阶段构建，仅打包 `nm760CD` + PsN，不包含 `install/` 里其他版本文件，体积约 **1.1–1.3GB**（旧版 `ADD install` 约 3.4GB）。

**主机使用**：

```bash
cd nm760
cp /path/to/nonmem.lic license/nonmem.lic
./install.sh

cd models
../execute CONTROL5.mod
../util/nmfe76 CONTROL5.mod OUTPUT5
```

### 直接调用 Docker（不经过 install.sh）

在模型目录执行时，把 `NM_ROOT` 换成对应版本目录，`TAG` 换成镜像标签，`NMFE` 换成 `nmfe74` / `nmfe75` / `nmfe76`：

```bash
NM_ROOT=/path/to/nonmem/nm750
TAG=kinginsun/nonmemmpi2:7.5.0
MODEL_DIR=$(pwd)

docker run --rm \
  --workdir /nonmem/models \
  -v ${NM_ROOT}/license:/nonmem/nm750/license \
  -v ${MODEL_DIR}:/nonmem/models \
  ${TAG} execute CONTROL5.mod

docker run --rm \
  --workdir /nonmem/nm750/util \
  -v ${NM_ROOT}/license:/nonmem/nm750/license \
  -v ${MODEL_DIR}:/nonmem/models \
  ${TAG} nmfe75 CONTROL5.mod OUTPUT5 -rundir=/nonmem/models
```

7.4.3 / 7.6.0 只需把路径中的 `nm750`、`nmfe75` 改为 `nm743`/`nmfe74` 或 `nm760`/`nmfe76`。

### 与 Pirana 整合

- **PsN executables location**：指向对应版本目录，如 `.../nonmem/nm750`
- **NONMEM**：同一目录；在 Pirana 里新建条目（如 `nm75`）并搜索可执行文件
- 通过 `nmfeXX` 运行时勾选 **Copy back results to main folder**，否则 Pirana 中可能看不到输出
- Pirana 下载（macOS 新版推荐 **2.9.9**）：https://s3.amazonaws.com/certara-pirana/pirana_2.9.9_MacOSX.dmg  
  旧版 2.9.8：https://www.evernote.com/l/ABkzIX34qFxOB6aqA1Sxk3pFat5VLDC0f9E  
  **无限期学术版** license 可向 [Certara](https://www.certara.com/software/pirana-modeling-workbench/) 申请

## Github源码

- 源码在 [kinginsun/nonmem](https://github.com/kinginsun/nonmem)

## 致谢

- [PsN](https://uupharmacometrics.github.io/PsN/docs.html),[Download](https://uupharmacometrics.github.io/PsN/download.html)
- [ICON](https://www.iconplc.com/innovation/nonmem/),[Download](https://nonmem.iconplc.com/)
- [Pirana](http://lp.certara.com/WFDownloadPirana.html)

## 问题1：pirana无法直接execute，不弹出terminal窗口

- 升级到macOS majove以后，pirana无法直接execute，在terminal检查nm72和PsN的命令都是没有问题的；发现是/usr/bin/xterm不存在造成的，由于不能在/usr/bin中增加软连接，只好在/usr/local/bin中增加xterm的软连接：
  - $ which xterm
  - $ sudo ln -s /opt/X11/bin/xterm /usr/local/bin/xterm
  - 然后设置pirana —> settings —> Software integration —> Other Terminal

- 增加软连接以后，还要把/usr/local/bin 加入pirana的环境变量中去Environment variable --> Add to PATH by Pirana
- 安装 Pirana license 后即可使用全部功能；无限期学术版 license 可向 Certara 联系申请获得

## 问题2：增加MPI支持

- nonmem743的CD中有mpich2目录，安装以后系统才有mpif90命令，同时要把 mpich2安装目录/lib/libmpich.a 中编译好的文件替换nm743安装目录/mpi/mpi_ling/libmpich.a，这里的默认是32位编译文件，运行会出错。
- ubuntu docker镜像默认没有python，需要安装
- 安装以后，配置本地的mpd.conf，设置目录权限600
- 为了在运行不同的PsN和nmfe74命令前，执行mpd，通过脚本 run 来处理，安装在 /usr/local/bin 中
- 最后将/nonmem/mpich2 和 /nonmem/nm743/util 加入PATH
- 上面设置只是实现了auto-MPI，
- auto-FPI 会将计算分布到多台主机上，配置还有待研究
- Pirana 通过 `nmfe74` / `nmfe75` / `nmfe76` 运行时需勾选：**Copy back results to main folder**，否则 Pirana 里看不到结果

## MPI：`execute` / `nmfeXX` 加 `-parafile=...` 启动并行

在对应版本 `models/` 下可使用自带的 `pirana_auto_mpi.pnm`，例如：

```bash
# 7.5.0 示例
../execute -parafile=pirana_auto_mpi.pnm CONTROL5.mod -nodes=4
../util/nmfe75 CONTROL5.mod OUTPUT5 "-parafile=pirana_auto_mpi.pnm" "[nodes]=4"
```

以下为 Windows 风格 pnm 示例（`execute, nmfe74` 增加参数 `-parafile=mpi_for_win.pnm`）：

```
$DEFAULTS
; User may specify their own variables with bracketed words at the nmfe72 script command line:
; nmfe72 myprog.ctl myres.res "-parafile=mpiwini8.pnm" "[nodes]=3"
; which will over-ride default settings of variables listed here (variables must be defined one
; variable per line).  If the file defaults.pnm exists, and it defines [nodes], this can also
; over-ride defaults listed in the parafile.
; Order of over-ride is Command line on nmfe72 script over-rides defaults.pnm,
; which over-rides defaults defined in parafile.
; The advantage to this ordering is that, a generic parafile file can be created for most environments.
; A user may then over-ride defaults specified in this generic parafile with his own in defaults.pnm,
; that may be more suitable to his environment.  Finally, a user can temporarily over-ride his own defaults
; by giving an alternative value as an nmfe72 script command option.
[nodes]=8

$GENERAL
; [nodes] is a User defined variable
;COMPUTERS=2
NODES=[nodes] PARSE_TYPE=2 PARSE_NUM=200 TIMEOUTI=600 TIMEOUT=1000 PARAPRINT=0 TRANSFER_TYPE=1
;SINGLE node: NODES=1
;MULTI node: NODES>1
;WORKER node: NODES=0
; parse_num=number of subjects to give to each node
; parse_type=0, give each node parse_num subjects
; parse_type=1, evenly distribute numbers of subjects among available nodes
; parse_type=2, load balance among nodes
; parse_type=3, assign subjects to nodes based on idranges
; parse_type=4, load balance among nodes, taking into account loading time.  Will assess ideal number of nodes.
; If loading time too costly, will eventually revert to single CPU mode.
; timeouti=seconds to wait for node to start.  if not started in time, deassign node, and give its load to next worker, until next iteration
; timeout=minutes to wait for node to compelte.  if not completed by then, deassign node, and have manager complete it.
; paraprint=1  print to console the parallel computing process.  Can be modified at runt-time with ctrl-B toggle.
; But parallel.log always records parallelization progress.
; transfer_type=0 for file transfer, 1 for mpi

;THE EXCLUDE/INCLUDE may be used to selectively use certain nodes, out of a large list.
;$EXCLUDE 5-7 ; exclude nodes 5-7
;$EXCLUDE ALL
;$INCLUDE 1,4-6

$COMMANDS ;each node gets a command line, used to launch the node session
; %* sends all arguments on the user's command line to the manager process
1:mpiexec -wdir "%cd%"  -localonly -n 1 nonmem.exe %*
; Only specific arguments should be sent to the workers, which are identified by reserved variable names
2-[nodes]:-wdir "%cd%\worker{#-1}" -n 1 nonmem.exe

$DIRECTORIES
1:NONE ; FIRST DIRECTORY IS THE COMMON DIRECTORY
2-[nodes]:worker{#-1} ; NEXT SET ARE THE WORKER directories

$IDRANGES ; USED IF PARSE_TYPE=3
1:61,100
2:1,60
```

## pirana自带的pnm文件：pirana_auto_mpi.pnm

```
$DEFAULTS
[nodes]=4

$GENERAL
NODES=[nodes] PARSE_TYPE=2 TIMEOUTI=20 TIMEOUT=500 PARAPRINT=1 TRANSFER_TYPE=1

$COMMANDS
1:mpirun -wdir "$PWD" -n 1 ./nonmem  $*
2-[nodes]:-wdir "$PWD/worker{#-1}" -n 1 ./nonmem

$DIRECTORIES
1:NONE ; Common directory
2-[nodes]:worker{#-1} ; Worker directories
```

## Pharmacometrics-Docker

- [Pharmacometrics-Docker](https://github.com/billdenney/Pharmacometrics-Docker)
