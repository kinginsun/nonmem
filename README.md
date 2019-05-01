## NONMEM 7.4.3 Docker镜像
* 此image基于ubuntu 16.04构建，整合了nonmem7.4.3和PsN4.8.1
* 目前只做了nmfe74和exceute的映射，可以在host主机直接调用；其他PsN命令可以类似的写个shell脚本
* 用户自己的license替换license目录中的nonmem.lic


## Mac,Ubuntu安装
* 运行nonmem目录中的 ./install.sh


## 与Pirana整合
* PsN的执行目录为nonmem的安装目录
* 设置nmfe74的目录为nonmem的安装目录


## 构建镜像
docker build -t kinginsun/nonmem:7.4.3 .

