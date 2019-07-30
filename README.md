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