---
layout: post
title: "iOS中的数据持久化之[Core Data]"
description: ""
category: '数据持久化'
tags: ['数据持久化']
---
{% include JB/setup %}


我们可以认为Core Data是对Sqlite等数据库的底层封装，当然不完全是，CoreData的底层存储机制除了可以使用Sqlite外，也可以使用二进制文件与XML文件等，Core Data使用面向对象方式处理底层的数据存储，也就是一般语言中常说的ORM功能。即Object Relational Mapping 对象关系映射。
Core Data其实是非常的复杂的，光讲Core Data的书都有很多，我这里面讲的是最基本的使用，想了解更高级的功能，可以参考一些CoreData的书籍（很多）。

<!--more-->

我们看一下Core Data的结构:

![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img1.jpg)   

从上图中，我们也看到了Core Data的数据结构:    
* 最上层是管理对象的上下文，也就是最上层对对象的GRUD（增删改查）。    
* Persistent Store Coordinator是负责持久化存储协调的，它与上层的Managed Object Context建立关联，并且使Managed object model与底层的数据持久层建立关联。    
* Persistent Store 显然就是负责对象的数据存储了。  

大家可能都发现了，我的这些文章中，理论的东西都是点到为止，只要掌握了我们实战需要的理论知识即可，而不是深究，我一般都会附上理论知识的链接地址，要详细了解这些设计原理与结构，可以直接查看附属的参考文档。

# 实战  

## 1. 新建工程,选中Use Core Data。  
![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img3.png)   

## 2.Xcode自动会创建一些必备的文件与代码,如果工程建立时并没有选中，就需要自己添加一些必备的代码与模型文件：

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


## 3.创建数据结构  
打开xcdatamodeld文件，添加2个实例对象，其实就是创建2个表，添加相应的属性与外键，创建数据模型时，以数据库的思想去看，去操作就很容易理解了，但是CoreData中建立外键关系稍有不同。

![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img5.png)   

![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img6.png)   

对相关联的数据表的相关字段建立相应的外键约束关系，一方面有助于我们的逻辑梳理，能够建立完善的数据模型，另一方面也有助于程序开发过程中的错误的检查，数据库会根据外键关系而避免一些程序的错误操作。

> CoreData的外键关系建立可以按如下方式:       
> * User中必然会有一个字段表示该user属于哪个group，我们在User对象中添加一个Relationship命名为group, Destination为Group.  
> * 在Group中添加一个反向关系，命名为user,Destination为User,Inverse为上一步为User建立的一个relationship：group。建立好此relationship过后，上一步在User对象中建立的Relationship中反向关系设置了的那条Relationship的Inverse也会自动设置为Group中相应的Relationship。

## 4.使用key-value Map(Dictionary)方式进行数据处理

{% highlight Objective-C %}
- (void)insertCoreDataTest{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    NSManagedObject *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [user setValue:@"罗国辉" forKey:@"name"];
    [user setValue:@18 forKey:@"age"];
    [user setValue:@"成都高新区" forKey:@"address"];
    [user setValue:@"1449210815" forKey:@"created_at"];
    [user setValue:@101 forKey:@"id"];
    
    NSManagedObject *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    [group setValue:@"研发组" forKey:@"name"];
    [group setValue:@222 forKey:@"id"];
    
    //Relationship
    [user setValue:group forKey:@"group"];
    [group setValue:user forKey:@"user"];
    
    //Save
    NSError *error;
    if(![context save:&error]){
        NSLog(@"Core Data save error:%@",[error localizedDescription]);
    }
    NSLog(@"insert core data completed..................");
}

- (void)fetchDataTest{
    NSLog(@"fetch core data test..................");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *user in fetchedObjects) {
        NSLog(@"id:%@",[user valueForKey:@"id"]);
        NSLog(@"name:%@",[user valueForKey:@"name"]);
        NSLog(@"age:%@",[user valueForKey:@"age"]);
        NSLog(@"address:%@",[user valueForKey:@"address"]);
        NSLog(@"address:%@",[user valueForKey:@"address"]);
        
        NSManagedObject *group = [user valueForKey:@"group"];
        
        NSLog(@"group Id:%@",[group valueForKey:@"id"]);
        NSLog(@"group Name:%@",[group valueForKey:@"name"]);
    }
}
{% endhighlight %}  

> PS:CoreData的对象模型中的数据类型属性中并没有AutoIncrement可使用，所以如果要使用这种ID需要自己实现，不论是另外维持一个ID处理的数据，还是使用NSManagedObjectID来实现。

## 5.使用对象模式进行数据处理  
像以上方式，即Dictionary方式进行数据读取，UserDefault数据存储也是这种方式，但这种处理显然是一种过程处理逻辑，我们使用对象的模式来处理。   
按以下方式新建模型类:  
![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img7.png)     
![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img8.png)     
![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img9.png)     

Xcode会自动为每个模型对象建立相应的对象类文件如下:    

![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img10.png)     

老版本的Core Data只会为每个模型对象建立一个.h文件，一个.m文件，但是现在新版本的Core Data有意将模型对象的属性与方法分开，所以会为每个模型对象建立2个.h文件，2个.m文件，其中一个是类定义，一个是其Category，而且属性定义是在Category中定义的，根据Apple的这种做法，也给开发者提供了很多标准。    
如下：    
Group模型对应的类文件:    
{% highlight Objective-C %}
//Group.h
//---------------------------------
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Group : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Group+CoreDataProperties.h"


//  Group.m
//---------------------------------
#import "Group.h"

@implementation Group

// Insert code here to add functionality to your managed object subclass

@end
{% endhighlight %}  



{% highlight Objective-C %}
//  Group+CoreDataProperties.h
//---------------------------------
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface Group (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSManagedObject *user;

@end

NS_ASSUME_NONNULL_END

//  Group+CoreDataProperties.m
//---------------------------------
#import "Group+CoreDataProperties.h"

@implementation Group (CoreDataProperties)

@dynamic id;
@dynamic name;
@dynamic user;

@end
{% endhighlight %}  

User 对象的模型类:    

{% highlight Objective-C %}
//  User.h
//---------------------------------
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"

//  User.m
//---------------------------------
#import "User.h"
#import "Group.h"

@implementation User

// Insert code here to add functionality to your managed object subclass

@end

//  User+CoreDataProperties.h
//---------------------------------
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSNumber *age;
@property (nullable, nonatomic, retain) NSString *created_at;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) Group *group;

@end

NS_ASSUME_NONNULL_END

//  User+CoreDataProperties.m
//---------------------------------
#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

@dynamic address;
@dynamic age;
@dynamic created_at;
@dynamic id;
@dynamic name;
@dynamic group;

@end

{% endhighlight %}  

建立好模型类过后，我们就可以修改一下上面的key-value方式:    
{% highlight Objective-C %}
- (void)insertCoreDataTest2{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    user.id = @111;
    user.name = @"Grey.Luo";
    user.address = @"成都高新区";
    user.age = @18;
    
    Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    group.id = @199;
    group.name = @"无线事业部";
    
    user.group = group;
    group.user = user;
    
    NSError *error;
    if(![context save:&error]){
        NSLog(@"Core Data save error:%@",[error localizedDescription]);
    }
}
- (void)fetchDataTest2{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (User *user in fetchedObjects) {
        NSLog(@"id:%@",user.id);
        NSLog(@"name:%@",user.name);
        NSLog(@"age:%@",user.age);
        NSLog(@"address:%@",user.address);
        
        Group *group = user.group;
        
        NSLog(@"group id:%@",group.id);
        NSLog(@"group name:%@",group.name);
    }
}
{% endhighlight %}  

为了更好的理解 CoreData，我们来看一下Core Data的工作过程,如下图所示，在scheme中添加运行参数，过后我们即可在终端中看到SQL执行过程:

![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img11.png)     

我们在数据持久助理中定义了数据存储的路径:  
{% highlight Objective-C %}
NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GLDataStore_CoreData.sqlite"];
{% endhighlight %}  
打开这个数据库文件看一下：    
![image]({{ site.attachment }}/posts/2015-12-01-datastore-coredata-img12.png)   
 
 具体CoreData在与底层的Sqlite交互处理时，为什么会这样建立数据表，就自己琢磨吧。  
 PS：打开易车、汽车之家、爱卡APP的目录，这种明显要使用车型数据库的APP，有使用CoreData的，也有使用plist的，也有使用sqlite。 下一篇
我们将会使用数据库的方式来实现数据的存储，下一篇学习过后，再回头看的时候，你可能会对Core Data有更深层的理解 。


参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！   

 > * [Core Data Core Competencies](https://developer.apple.com/library/prerelease/mac/documentation/DataManagement/Devpedia-CoreData/coreDataStack.html#//apple_ref/doc/uid/TP40010398-CH25-SW1)  
 > * [Core Data Programming Guide](https://developer.apple.com/library/prerelease/mac/documentation/Cocoa/Conceptual/CoreData/index.html#//apple_ref/doc/uid/TP40001075-CH2-SW1)  
 > * [Core Data](http://www.raywenderlich.com/tag/core-data)

