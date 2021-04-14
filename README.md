<!--
 * @Author: Alan
 * @Date: 2021-04-13 17:26:38
 * @LastEditTime: 2021-04-14 17:31:54
 * @LastEditors: Alan
 * @Description: 
 * 
-->
*一、简单说明：*
>1、基于 #1and1internet/ubuntu-16-nginx-php-7.2# 修改的nginx-php-fmp dockerfile ，可用于平时快速部署一个开发环境

>2、使用的环境配置：php7.2 + unbunt-16 + nginx ，详细的驱动信息可以查看dockerfile 


*二、根据dockerfile 生成 镜像，命令如下：*


***1、 docker build打包生成镜像***

```
    docker build -f xxx(文件路径) -t xxx:xx(仓库:tag) .(上下文)

```

***2、docker run 创建一个新的容器并运行一个命令***
```
docker run -d -u 999:0 -p 8080:8080 -p 80:8080 -v xxx(宿主机WW路径):/var/www/  -v  xxx(宿主机log路径):/var/log/  -v xxx/(宿主机nginx 配置文件路径):/etc/nginx/sites-enabled  --name php7.2-fpm php7.2-nginx-fpm:v1
```

***3、docker save 将指定镜像保存成 tar 归档文件***
```
docker save xxx(镜像id) -o (操作方式) xxx(生成的包名).tar
```

*三、快速使用步骤如下：*

>1、下载tars文件下的 php7.2-nginx-fpm.tar 包 
>2、宿主机的www站立按照tars 中data 新建文件夹

>3、使用命令导入包：
```
    docker load < ./php7.2-nginx-fpm.tar
```

>4、使用命令创建一个新的容器并运行一个命令：

```
    docker run -d -u 999:0 -p 8080:8080 -p 80:8080 -v xxx(宿主机WW路径):/var/www/  -v  xxx(宿主机log路径):/var/log/  -v xxx/(宿主机nginx 配置文件路径):/etc/nginx/sites-enabled  --name php7.2-fpm php7.2-nginx-fpm:v1
```
>5、 根据以上步骤处理后则可开始进行本地web开发








    


