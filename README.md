## 说明
* 此image基于ubuntu 16.04构建，整合了nonmem7.4.3和PsN4.8.1
* 目前只做了nmfe74和execute的映射，可以在host主机直接调用；其他PsN命令可以类似的写个shell脚本
* 用户自己的license替换license目录中的nonmem.lic


## Mac,Ubuntu安装
+ 项目clone到本地：git clone git@github.com:kinginsun/nonmem.git
+ 运行nonmem对应版本目录中的 ./install.sh


## 与Pirana整合
* PsN的执行目录指向此项目nonmem中对应版本的目录，比如NONMEM 7.4.3就指向nm743
* nonmem的目录指向此项目nonmem中对应版本的目录，比如NONMEM 7.4.3就指向nm743


## 构建镜像
docker build -t kinginsun/nonmem:7.4.3 .

