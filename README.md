## 说明
* 此image基于ubuntu 16.04构建，整合了nonmem7.4.3和PsN4.8.1
* 目前只做了nmfe74和execute的映射，可以在host主机直接调用；其他PsN命令可以类似的写个shell脚本
* 用户自己的license替换license目录中的nonmem.lic


## Mac,Ubuntu安装
+ 项目clone到本地：git clone https://github.com/kinginsun/nonmem.git
+ 运行nonmem对应版本目录中的 ./install.sh


## 与Pirana整合
* PsN的执行目录指向此项目nonmem中对应版本的目录，比如NONMEM 7.4.3就指向nm743
* nonmem的目录指向此项目nonmem中对应版本的目录，比如NONMEM 7.4.3就指向nm743
* Pirana下载：https://www.evernote.com/l/ABkzIX34qFxOB6aqA1Sxk3pFat5VLDC0f9E

## 使用
- execute CONTROL5.mod (命令行切换到mod所在目录，然后直接execute + mod文件，结果输出到当前目录)
- nmfe74 CONTROL5.mod OUTPUT5.txt (nmfe74需指定模型和输出文件，结果也是输出到当前目录)

## 构建镜像
docker build -t kinginsun/nonmem:7.4.3 .

docker build -f Dockerfile.mpi -t kinginsun/nonmemmpi:7.4.3 .

## Github源码
- 源码在 [kinginsun/nonmem](https://github.com/kinginsun/nonmem) 

## 致谢
- [PsN](https://uupharmacometrics.github.io/PsN/docs.html),[Download](https://uupharmacometrics.github.io/PsN/download.html)
- [ICON](https://www.iconplc.com/innovation/nonmem/),[Download](https://nonmem.iconplc.com/)
- [Pirana](http://lp.certara.com/WFDownloadPirana.html)

## 与Pirana整合
* settings
  - PsN executables location: /Users/randyz/Documents/nonmem/nm743
  - NONMEM: /Users/randyz/Documents/nonmem/nm743， 起个名字nm74,指向这个路径，然后搜索

## 问题1：pirana无法直接execute，不弹出terminal窗口

 - 升级到macOS majove以后，pirana无法直接execute，在terminal检查nm72和PsN的命令都是没有问题的；发现是/usr/bin/xterm不存在造成的，由于不能在/usr/bin中增加软连接，只好在/usr/local/bin中增加xterm的软连接：
    - $ which xterm
    - $  sudo ln -s /opt/X11/bin/xterm /usr/local/bin/xterm
    - 然后设置pirana —> settings —> Software integration —> Other Terminal

- 增加软连接以后，还要把/usr/local/bin 加入pirana的环境变量中去Environment variable --> Add to PATH by Pirana
- pirana安装license就可以使用所有功能

## 问题2：增加MPI支持
 - nonmem743的CD中有mpich2目录，安装以后系统才有mpif90命令，同时要把 mpich2安装目录/lib/libmpich.a 中编译好的文件替换nm743安装目录/mpi/mpi_ling/libmpich.a，这里的默认是32位编译文件，运行会出错。
 - ubuntu docker镜像默认没有python，需要安装
 - 安装以后，配置本地的mpd.conf，设置目录权限600
 - 为了在运行不同的PsN和nmfe74命令前，执行mpd，通过脚本 run 来处理，安装在 /usr/local/bin 中
 - 最后将/nonmem/mpich2 和 /nonmem/nm743/util 加入PATH
 - 上面设置只是实现了auto-MPI，
 - auto-FPI 会将计算分布到多台主机上，配置还有待研究

## execute, nmfe74 增加参数 “-parafile=mpi_for_win.pnm” 即可启动MPI，示例的windows pnm文件如下：
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

## Pirana通过nmfe74命令运行时需勾选：Copy back results to main folderr，否则pirana里面看不到结果