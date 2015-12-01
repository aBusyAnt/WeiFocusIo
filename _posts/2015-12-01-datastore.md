---
layout: post
title: "iOS中的数据持久化之[NSUserDefault]"
description: ""
category: '数据持久化'
tags: ['数据持久化']
---
{% include JB/setup %}
任何语言、平台的开发都会涉及到数据的存储问题，我们称之为数据的持久化，在iOS中必然也会有这种应用场景，比如数据缓存、自动登录信息、不 变的固话信息等等。

iOS中的数据持久化有以下几种方式: 

* NSUserDefault
* 自定义文件
* CoreData
* Sqlite或其它数据库

<!--more-->

# 一. NSUserDefault
这种是最简单的一种数据存储方式，非常的轻量级，其实就是建立的一个Plist文件，也就是XML文件。存储的数据必须是可序列化的数据，如NSString、NSNumber、NSDate、NSDictionary、NSArray、NSData.
如果是自定交对象，则必须先要进行归档，然后才能存入NSUserDefault中，所谓归档，其实就是使用NSCoding协议将自定义对象转换成010100...这种序列。

我们先来试一下默认支持的类型:

{% highlight Objective-C %}

#define kName @"name"
#define kAge  @"age"
#define kSkills @"skills"
#define kExperience1 @"experience1"
#define kExperiences @"experiences"


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *name = [userDefault objectForKey:kName];
    if (name) {
        [self normalUserdefaultTestRead];
    }else{
        NSLog(@"......None Data in UserDefault ......");
        [self normalUserdefaultTestWrite];
        [self normalUserdefaultTestRead];
    }
}


- (void)normalUserdefaultTestWrite{
    
    //build test data
    NSString *name = @"Grey.luo";
    NSNumber *age = @18;
    NSArray *skills = @[@"扯蛋",@"寻蛋",@"生蛋"];
    NSDictionary *experience1 = @{@"content":@"嵌入式开发",@"address":@"成都青羊"};
    NSDictionary *experience2 = @{@"content":@"iOS开发",@"address":@"成都高新"};
    NSDictionary *experience3 = @{@"content":@"全栈开发",@"address":@"成都高新区"};
    NSArray *experiences = @[experience1,experience2,experience3];
    
    //存入数据
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:name forKey:kName];
    [userDefault setObject:age forKey:kAge];
    [userDefault setObject:skills forKey:kSkills];
    [userDefault setObject:experience1 forKey:kExperience1];
    [userDefault setObject:experiences forKey:kExperiences];
    [userDefault synchronize];//同步写入磁盘
    
}

- (void)normalUserdefaultTestRead{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *name = [userDefault objectForKey:kName];
    NSNumber *age = [userDefault objectForKey:kAge];
    NSArray *skills = [userDefault objectForKey:kSkills];
    NSDictionary *experience1 = [userDefault objectForKey:kExperience1];
    NSArray *experiences  = [userDefault objectForKey:kExperiences];
    
    NSLog(@"name : %@",name);
    NSLog(@"age : %@",age);
    NSLog(@"skills : %@",[skills description]);
    NSLog(@"experience1 : %@",[experience1 description]);
    NSLog(@"experiences : %@",[experiences description]);
    
}
{% endhighlight %}  

看一下运行结果中读取出来的数据:
![image]({{ site.attachment }}/posts/2015-12-01-datastore-img1.png)   

再看一下存储的plist文件:
找到模拟器中该Plist所在路径:
> /Users/xxx/Library/Developer/CoreSimulator/Devices/6B7775CC-6306-4A6E-BD2F-415901F1E412/data/Containers/Data/Application/3958BD1F-EB56-4EE0-A288-D4DBC0D1B717/Library/Preferences/com.weifocusio.GLDataStoreDemo.plist

文件内容:
![image]({{ site.attachment }}/posts/2015-12-01-datastore-img2.png)   


再来看一下自定义对象：
元数据一个一个的平等存储太过繁琐，一般更多的是以对象的方式一次性处理、存储，我们先不进行归档序列化试一下:

{% highlight Objective-C %}
//定义User
@interface User : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic)  int age;
@property (nonatomic,strong) NSArray *skills;
@property (nonatomic,strong) NSDictionary *experience1;
@property (nonatomic,strong) NSArray *experiences;

@end

//
- (void)customObjectTestWrite{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    User *user = [[User alloc]init];
    user.name = @"Grey.luo";
    user.age = 18;
    user.skills = @[@"扯蛋",@"寻蛋",@"生蛋"];
    
    NSDictionary *experience1 = @{@"content":@"嵌入式开发",@"address":@"成都青羊"};
    NSDictionary *experience2 = @{@"content":@"iOS开发",@"address":@"成都高新"};
    NSDictionary *experience3 = @{@"content":@"全栈开发",@"address":@"成都高新区"};

    NSArray *experiences = @[experience1,experience2,experience3];
    user.experience1 = experience1;
    user.experiences = experiences;
    
    
    [userDefault setObject:user forKey:@"user"];
    [userDefault synchronize];
}


- (void)customObjectTestRead{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    User *user = [userDefault objectForKey:@"user"];
    NSLog(@"user : %@",[user description]);
    
}
{% endhighlight %}  

结果运行报错：
![image]({{ site.attachment }}/posts/2015-12-01-datastore-img3.png)   
就是提示试图写入非序列化的数据。

我们来修改一下，添加NSCoding序列化:

{% highlight Objective-C %}
@interface User : NSObject<NSCoding>

@property (nonatomic,strong) NSString *name;
@property (nonatomic)  int age;
@property (nonatomic,strong) NSArray *skills;
@property (nonatomic,strong) NSDictionary *experience1;
@property (nonatomic,strong) NSArray *experiences;

- (void)description;
@end

@implementation User
- (id)initWithCoder:(NSCoder *)coder{
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _age = [coder decodeIntForKey:@"age"];
        _skills = [coder decodeObjectForKey:@"skills"];
        _experience1 = [coder decodeObjectForKey:@"experience1"];
        _experiences = [coder decodeObjectForKey:@"experiences"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeInt:_age forKey:@"age"];
    [coder encodeObject:_skills forKey:@"skills"];
    [coder encodeObject:_experience1 forKey:@"experience1"];
    [coder encodeObject:_experiences forKey:@"experiences"];
}

- (void)description{
    NSLog(@"name : %@",_name);
    NSLog(@"age : %d",_age);
    NSLog(@"skills : %@",[_skills description]);
    NSLog(@"experience1 : %@",[_experience1 description]);
    NSLog(@"experiences : %@",[_experiences description]);
}
@end
{% endhighlight %}  



{% highlight Objective-C %}
- (void)customObjectTestWrite{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    User *user = [[User alloc]init];
    user.name = @"Grey.luo";
    user.age = 18;
    user.skills = @[@"扯蛋",@"寻蛋",@"生蛋"];
    
    NSDictionary *experience1 = @{@"content":@"嵌入式开发",@"address":@"成都青羊"};
    NSDictionary *experience2 = @{@"content":@"iOS开发",@"address":@"成都高新"};
    NSDictionary *experience3 = @{@"content":@"全栈开发",@"address":@"成都高新区"};

    NSArray *experiences = @[experience1,experience2,experience3];
    user.experience1 = experience1;
    user.experiences = experiences;
    //归档
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
    [userDefault setObject:userData forKey:@"user"];
    [userDefault synchronize];
}


- (void)customObjectTestRead{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefault objectForKey:@"user"];
    //解档
    User *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [user description];
}
{% endhighlight %}  
运行结果:  
![image]({{ site.attachment }}/posts/2015-12-01-datastore-img4.png)   

# 二. 自定义文件
这个就不多讲了，就是按自己定义的格式写入文件，从文件读出数据并解析，这种方式一般是比较底层的操作，比较在C/C++中我们一般都会要自己处理这种文件的写入与读取的解析处理。但是上层的应用，我们的主要精力应该放在业务处理上，而不应该在这种底层功能上浪费太多时间。

