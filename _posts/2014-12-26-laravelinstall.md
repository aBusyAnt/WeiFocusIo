---
layout: post
title: "Laravel Sentry扩展"
description: ""
category: "Laravel"
tags: ['Laravel']
---
{% include JB/setup %}

[Sentry](https://cartalyst.com/manual/sentry)，它是一个简单，容易使用，但是功能还是比较强大的一个扩展包。它提供用户授权、身份验证、用户组、权限控制、自定义HASH算法等等。 
<!--more-->

###Laravel安装    
1、Laravel的安装很简单，直接安装官网的文档提供的3种方式来整就行了，要求PHP>=5.4，MCrypt PHP 扩展.  
2、更改为debug模式  
3、为app/storage开写权限: 

	sudo chmod -R 777 app/storage/  

###安装配置Sentry扩展    

安装方法：

在composer.json中的require中添加sentry的支持： 

	"require": {
        "cartalyst/sentry": "2.1.4",
    },

在配置文件app/config/app.php 中的provider数组中添加供应商：

	'Cartalyst\Sentry\SentryServiceProvider',

还是在上面的配置文件中的别名数组alias中添加：

	'Sentry' => 'Cartalyst\Sentry\Facades\Laravel\Sentry',

更新依赖包:

	composer update

配置数据库连接：～/app/config/database.php

Migrations迁移，为Sentry建立用户模块数据表：

	php artisan migrate --package=cartalyst/sentry

此时有可能会出错，提示找不到此目录，是因为找不到mysql文件：mysql.sockt，它是用于服务器与本地客户端的通信的Unix套接字文件。
我们在mysql的配置添加上咱们mysql的文件就行了。
	
	'unix_socket'   =>      '/tmp/mysql.sock',

现在再来执行：php artisan migrate --package=cartalyst/sentry  

现在就可以在数据库中看到5张表:users,users_groups,groups,throttle,migrations.

OK，现在安装完成后，就可以发布包配置文件到应用程序:
	php artisan config:publish cartalyst/sentry

这将发布配置文件，app/config/packages/cartalyst/sentry/config.php


###Sentry使用






