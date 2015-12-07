---
layout: post
title: "iOS中的数据持久化之[Sqlite]"
description: ""
category: '数据持久化'
tags: ['数据持久化']
---
{% include JB/setup %}

数据库是所有平台都支持的，所以iOS中进行数据存储肯定也可以使用数据库，常用的小形数据库，比如Sqlite,Berkeley DB等，使用最流行的就是关系形数据库Sqlite。


<!--more-->

## 1.Sqlite的原生API使用

以下是一个最简单的sqlite的使用示例:
{% highlight Objective-C %}
- (void)sqliteTest{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    sqlite3 *db;
    NSString *database_path = [documents stringByAppendingPathComponent:@"sqliteTest.sqlite"];
    NSLog(@"database path:%@",database_path);
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"Open DB Error");
    }
    
    //create table
    NSString *sql_drop = @"drop table if exists `User`";
    NSString *sql_create = @"create table `User`(`id` INTEGER not null PRIMARY KEY AUTOINCREMENT,`name` varchar(32) not null,`age` int(11) not null,`address` varchar(255),`group_id` int(11) not NULL, FOREIGN KEY(`group_id`) REFERENCES `group`(id))";
    
    NSString *sql_drop2 = @"drop table if exists `Group`";
    NSString *sql_create2 = @"create table `Group`(`id` INTEGER not null PRIMARY KEY AUTOINCREMENT, `name` varchar(32) not null)";
    
    [self execSql:sql_drop db:db];
    [self execSql:sql_create db:db];
    
    [self execSql:sql_drop2 db:db];
    [self execSql:sql_create2 db:db];
    
    //insert data test
    NSString *sql_insert = @"insert into 'Group'('name') values('研发组')";
    NSString *sql_insert2 = [NSString stringWithFormat:@"insert into `User` (`name`,`age`,`address`,`group_id`) values ('%@','%@','%@','%@')",@"Grey.Luo",@"18",@"成都高新",@1];
    
    [self execSql:sql_insert db:db];
    [self execSql:sql_insert2 db:db];
    
    //read data    
    NSString *query_sql = @"select * from User";
    sqlite3_stmt *statement = nil;
    
    if(sqlite3_prepare_v2(db, [query_sql UTF8String], -1, &statement, NULL) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int uid = sqlite3_column_int(statement, 0);
            
            char *name = (char *)sqlite3_column_text(statement, 1);
            NSString *nameOb = [NSString stringWithFormat:@"%s",name];
            
            NSLog(@"id:%d,name:%@",uid,nameOb);
        }
    }
    sqlite3_close(db);
}


- (void)execSql:(NSString *)sql db:(sqlite3 *)db{
    char *error;
    if(sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK){
        sqlite3_close(db);
        NSLog(@"exec sql error:%s",error);
    }
}
{% endhighlight %}  


## 2.Sqlite的封装FMDB

sqlite的原生API使用起来太过低级，为了更方便使用，我们一般采用FMDB等第三方封装库来进行sqlite的数据库操作。  

> FMDB源码及使用文档:https://github.com/ccgus/fmdb

{% highlight Objective-C %}
#pragma mark - FMDB
- (void)fmdbTest{
    //
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:@"sqliteTest2.sqlite"];

    FMDatabase *db = [FMDatabase databaseWithPath:database_path];
    if(![db open]){
        NSLog(@"Open db failed");
        return;
    }
    //
    NSString *sql_drop = @"drop table if exists `User`";
    NSString *sql_create = @"create table `User`(`id` INTEGER not null PRIMARY KEY AUTOINCREMENT,`name` varchar(32) not null,`age` int(11) not null,`address` varchar(255),`group_id` int(11) not NULL, FOREIGN KEY(`group_id`) REFERENCES `group`(id))";
    if (![db executeUpdate:sql_drop]) {
        NSLog(@"execupdate error:%@",sql_drop);
    }
    if(![db executeUpdate:sql_create]){
        NSLog(@"execupdate error:%@",sql_create);
    }
    
    NSString *sql_drop2 = @"drop table if exists `Group`";
    NSString *sql_create2 = @"create table `Group`(`id` INTEGER not null PRIMARY KEY AUTOINCREMENT, `name` varchar(32) not null)";
    if (![db executeUpdate:sql_drop2]) {
        NSLog(@"execupdate error:%@",sql_drop2);
    }
    if(![db executeUpdate:sql_create2]){
        NSLog(@"execupdate error:%@",sql_create2);
    }
    
    //
    NSString *sql_insert = @"insert into 'Group'('name') values('研发组')";
    NSString *sql_insert2 = [NSString stringWithFormat:@"insert into `User` (`name`,`age`,`address`,`group_id`) values ('%@','%@','%@','%@')",@"Grey.Luo",@"18",@"成都高新",@1];
    if (![db executeUpdate:sql_insert]) {
        NSLog(@"execupdate error:%@",sql_insert);
    }
    if(![db executeUpdate:sql_insert2]){
        NSLog(@"execupdate error:%@",sql_insert2);
    }
    //
    NSString *querySql = @"select * from User";
    FMResultSet *rs = [db executeQuery:querySql];
    while ([rs next]) {
        int uid = [rs intForColumn:@"id"];
        NSString *name = [rs stringForColumn:@"name"];
        int age = [rs intForColumn:@"age"];
        NSString *address = [rs stringForColumn:@"address"];
        int groupId = [rs intForColumn:@"group_id"];
        NSLog(@"%d-%@-%d-%@-%d",uid,name,age,address,groupId);
    }
    //
    [db close];
}
{% endhighlight %}  

我们在数据库操作，特别是写的时候，要保证线程安全，而FMDB提供了FMDatabaseQueue，用于线程安全的数据库操作。  
我们建立2个线程同时写相同的数据表，看一下执行过程:  
{% highlight Objective-C %}
- (void)fmdbQueueTest{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:@"sqliteTest2.sqlite"];

    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:database_path];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_queue_t q2 = dispatch_queue_create("queue2", NULL);
    dispatch_async(q1, ^{
        for (int i = 0; i< 100; i++) {
            [queue inDatabase:^(FMDatabase *db) {
                NSString *sql_insert = @"insert into 'Group'('name') values('研发组')";
                NSString *sql_insert2 = [NSString stringWithFormat:@"insert into `User` (`name`,`age`,`address`,`group_id`) values ('%@','%@','%@','%@')",@"Grey.Luo",@"18",@"成都高新",@1];
                if([db executeUpdate:sql_insert]){
                    NSLog(@"[1]insert into data:%@",sql_insert);
                }
                if([db executeUpdate:sql_insert2]){
                    NSLog(@"[1]insert into data:%@",sql_insert2);
                }
            }];
        }
    });
    
    dispatch_async(q2, ^{
        for (int i = 0; i< 100; i++) {
            [queue inDatabase:^(FMDatabase *db) {
                NSString *sql_insert = @"insert into 'Group'('name') values('研发组')";
                NSString *sql_insert2 = [NSString stringWithFormat:@"insert into `User` (`name`,`age`,`address`,`group_id`) values ('%@','%@','%@','%@')",@"Grey.Luo",@"18",@"成都高新",@1];
                if([db executeUpdate:sql_insert]){
                    NSLog(@"[2]insert into data:%@",sql_insert);
                }
                if([db executeUpdate:sql_insert2]){
                    NSLog(@"[2]insert into data:%@",sql_insert2);
                }
            }];
        }
    });
}
{% endhighlight %}  

![image]({{ site.attachment }}/posts/2015-12-01-datastore-sqlite-img1.png)   


数据库操作有很多种方法，本篇只是讲一些基本的操作。

本文源代码:[GLDataStore-CoreData](https://github.com/GrayLuo/GLDataStore-CoreData)

