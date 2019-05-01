docker build -t kinginsun/nonmem:7.4.3 .

docker tag 

docker run --name nonmem --rm -it kinginsun/nonmem:7.4.3 bash

unzip -P zorx7bqRT NONMEM7.4.3.zip

/bin/bash ./nm743CD/SETUP74 ${PWD}/nm743CD /nonmem/nm743 gfortran y /usr/bin/ar same rec q 


docker login --username=kinginsun --email=zyf@xanda.cn

# 直接运行命令
docker run --rm --name nonmem2 --workdir /nonmem/nm743/run -v ${PWD}/license:/nonmem/nm743/license kinginsun/nonmem:7.4.3 /bin/bash nmfe74 CONTROL5 test


