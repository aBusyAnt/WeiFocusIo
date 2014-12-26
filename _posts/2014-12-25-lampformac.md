---
layout: post
title: "配置Apache+PHP+MySQL"
description: ""
category: "PHP"
tags: []
---
{% include JB/setup %}

我们采用LAMP的架构进行开发，即Linux+Apache+MySQL+PHP,其中的Linux在这里我们用Mac替代，如果使用Linux，
<!--more-->
请参考<a href="{{ site.attachment }}/files/j2ee_lamp_install.txt"> 这篇文档</a>。

一.Apache配置  

1、测试，在浏览器里访问http://localhost，正常显示"It wordks !"  
2、我们可以看到Apache的默认访问目录如下：    

	DocumentRoot "/Library/WebServer/Documents"
	<Directory "/Library/WebServer/Documents">

3、借助于Apache的用户模块，我们为当前用户添加一个站点(由于apache的用户模块配置设置的目录名为Sites,如果要更改就要更改其配置，这里就直接用这个),并添加测试页面  

	mkdir ~/Sites
	echo "hello ,Cash !" >>index.html

4、添加用户站点目录信息，将username更改为当前用户名：

	<Directory "/Users/username/Sites/">
	　　   Options Indexes MultiViews
	　　   AllowOverride All
	　　   Order allow,deny
	　　   Allow from all
	</Directory>

5、修改apache2配置，加载必要的模块，去掉以下配置前的注释符＃：

	LoadModule php5_module libexec/apache2/libphp5.so

	LoadModule authz_core_module libexec/apache2/mod_authz_core.so
	LoadModule authz_host_module libexec/apache2/mod_authz_host.so

	LoadModule userdir_module libexec/apache2/mod_userdir.so

	Include /private/etc/apache2/extra/httpd-userdir.conf

6、修改apache的用户目录信息：
	
	sudo vim /etc/apache2/extra/httpd-userdir.conf
	将Include /private/etc/apache2/users/*.conf的注释符去掉

7、修改apache访问权限:

	sudo vim /etc/apache2/httpd.conf
	将  
	<Directory />
    	AllowOverride none
    	Require all denied
	</Directory>
	修改为  
	<Directory />
    	AllowOverride none
    	Require all granted
	</Directory>

8、重启测试：
	sudo apachectl restart
	打开浏览器，访问http://localhost/~username/,正常显示"hello ,Cash !"

二、配置PHP
目前PHP暂时根本不需要配置，我们只需要直接使用其默认的配置文件即可：

	sudo cp /etc/php.ini.default /etc/php.ini

添加一个php测试页面，将上面的index.html修改一下：

	mv ~/Sites/index.html ~/Sites/index.php
	vim ~/Sites/index.php
	输入：<?php phpinfo()?>

打开浏览器访问：	http://localhost/~username/
正常显示 PHP 的相关信息就OK了。

##特别说明一点：  
由于我们后面的服务端开发使用的是Laravel，而Laravel框架依赖Mcrypt库，所以还要安装这个库，如果上面安装PHP的时候已经安装了就可以忽略。

1、测试一下有没有安装：php -m  

2、下载[libmcrypt库](http://nchc.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz)与[php源码](http://cn2.php.net/distributions/php-5.5.12.tar.gz)  。  

3、编译libmcrypt :    

	./configure
	make
	sudo make install

4、编译php及扩展:

	cd ~/php-5.5.12/ext/mcrypt/
	phpize
	make
	sudo make install  
	安装完成过后会提示mcrypt.so安装在哪个目录如：
	/usr/local/lib/php/extensions/no-debug-non-zts-20121212/mcrypt.so

5、如果原来安装过了php，有可能环境配置中的php并不是当前编译的。  
	使用which php 可以看到当前使用的是哪个php  
6、修改php.ini

	在尾部添加：extension=mcrypt.so
	修改扩展的路径：  
	extension_dir = "/usr/local/lib/php/extensions/no-debug-non-zts-20121212"
如果一切OK，使用php -m 应该可以查看到mcrypt,或者在刚才的测试页面应该可以看到mcrypt被激活了。

三、MySQL

MySQL的配置太通用了，安装->配置用户名密码->设置相关用户的访问主机与权限，就这么简单就不浪费时间了。

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * http://doc.okbase.net/long-gengyun/archive/110953.html
> * http://coolestguidesontheplanet.com/how-to-install-mcrypt-for-php-on-mac-osx-lion-10-7-development-server/
