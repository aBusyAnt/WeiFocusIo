---
layout: post
title: "iOS中的数据持久化之[Core Data]"
description: ""
category: '数据持久化'
tags: ['数据持久化']
---
{% include JB/setup %}


我们可以认为Core Data是对Sqlite等数据库的底层封装，当然不完全是，CoreData的底层存储机制除了可以使用Sqlite外，也可以使用二进制文件与XML文件等，Core Data使用面向对象方式处理底层的数据存储，也就是一般语言中常说的ORM功能。即Object Relational Mapping 对象关系映射。
Core Data其实是非常的复杂的，我们目前只涉及一些使用比较多的使用方法，如需

<!--more-->

我们看一下Core Data的结构:

![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img1.jpg)   

从上图中，我们也看到了Core Data的数据结构:    
* 最上层是管理对象的上下文，也就是最上层对对象的GRUD（增删改查）。    
* Persistent Store Coordinator是负责持久化存储协调的，它与上层的Managed Object Context建立关联，并且使Managed object model与底层的数据持久层建立关联。    
* Persistent Store 显然就是负责对象的数据存储了。  

大家可能都发现了，我的这些文章中，理论的东西都是点到为止，只要掌握了我们实战需要的理论知识即可，而不是深究，我一般都会附上理论知识的链接地址，要详细了解这些设计原理与结构，可以直接查看附属的参考文档。

# 实战  

1. 新建工程,选中use Core Data。  
![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img3.png)   

2.Xcode自动会创建一些必备的文件与代码,如果工程建立时并没有选中，就需要自己添加一些必备的代码与模型文件：

首先是后缀为.xcdatamodeld的文件，也就是模型文件，我们通过这个模型文件建立数据存储模型，相当于表结构吧。

![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img4.png)   

其次会在AppDelegate中创建必备的代码:

{% highlight Objective-C %}
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
{% endhighlight %}  


{% highlight Objective-C %}
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.weifocusio.GLDataStore_CoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GLDataStore_CoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GLDataStore_CoreData.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
{% endhighlight %}  







参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！   

 > * [Core Data Core Competencies](https://developer.apple.com/library/prerelease/mac/documentation/DataManagement/Devpedia-CoreData/coreDataStack.html#//apple_ref/doc/uid/TP40010398-CH25-SW1)  
 > * [Core Data Programming Guide](https://developer.apple.com/library/prerelease/mac/documentation/Cocoa/Conceptual/CoreData/index.html#//apple_ref/doc/uid/TP40001075-CH2-SW1)  
 > * [Core Data](http://www.raywenderlich.com/tag/core-data)

