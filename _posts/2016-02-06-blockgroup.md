---
layout: post
title: "Asynchronous Block Group"
description: ""
category: 'foundation'
tags: ['foundation']
---
{% include JB/setup %}


在实际开发过程中，我们经常会遇到这样一种情况：需要多个函数执行结果进行最终的处理，但是这些函数中又包含了异步或者多线程代码块，我们如何才能保证在这些函数中的异步代码块执行结束后再进行最终的处理呢？有没有什么通用又优雅的方式呢？我遇到这种情况后，第一反应就是使用runtime为每个函数传入参数，在block结束后对参数进行更新、或者回调，再加上KVO对键值进行监视，可能这种方式可行。这里，我们先抛开优雅不说，用另一种方式来实现试下，这就是block的group属性。
<!--more-->
我们先定义一个示例：
{% highlight Objective-C %}

typedef void (^RequestCompleted)(id object);

@interface Client : NSObject
- (void)get:(NSString *)url inBackground:(BOOL)isBackground callback:(RequestCompleted)requestCompleted;
+ (Client *)sharedInstance;
@end

@implementation Client
+ (Client *)sharedInstance{
    static Client *_sharedInstance = nil;
    static dispatch_once_t oneceToken;
    dispatch_once(&oneceToken,^{
        _sharedInstance = [[Client alloc]init];
    });
    return _sharedInstance;
}

- (void)get:(NSString *)url inBackground:(BOOL)isBackground callback:(RequestCompleted)requestCompleted{
    NSString *encodeUrlStr = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrlStr]];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSLog(@"errorInfo:[%ld]",(long)error.code);
        NSLog(@"result:%@",[[NSString  alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        requestCompleted(data);
    }]resume];
}
@end
{% endhighlight %}

{% highlight Objective-C %}
- (void)func1:(BOOL)isRefresh{
    //...
    NSLog(@"func1 start......");
    Client *client = [Client sharedInstance];
    [client get:@"http://www.weather.com.cn/data/sk/101010100.html" inBackground:YES callback:^(id object) {
        NSLog(@"result:%@",object);

        NSLog(@"func1 block end......");
    }];
    NSLog(@"func1 end......");
}

- (void)func2:(BOOL)isRefresh{
    //...
    NSLog(@"func2 start......");
    Client *client = [Client sharedInstance];
    [client get:@"http://www.weather.com.cn/data/sk/101010100.html" inBackground:YES callback:^(id object) {
        NSLog(@"result:%@",object);

        NSLog(@"func2 block end......");
    }];
    NSLog(@"func2 end......");
}
{% endhighlight %}

{% highlight Objective-C %}
[self func1:YES];
[self func2:YES];
{% endhighlight %}

很简单的一个示例，就是2个方法，其内部又调用了异步代码块，我们看一下执行的结果:  
![image]({{ site.attachment }}/posts/2016-02-06-blockgroup_1.png)
从结果中我们可以看到方法很块就返回了，并不会等待异步代码块结束，所以我们只有捕获异步块的结束才能达到我们的目地。
我们根据[多线程编程](http://grayluo.github.io/WeiFocusIo/foundation/2015/12/10/thread/)一章中的dispatch_group_notify与NSBlockOperation可以得到启示:  
![image]({{ site.attachment }}/posts/2016-02-06-blockgroup_2.png)  

![image]({{ site.attachment }}/posts/2016-02-06-blockgroup_3.png)  

我们改造一下:
{% highlight Objective-C %}
- (void)func1:(BOOL)isRefresh{
    //...
    NSLog(@"func1 start......");
    Client *client = [Client sharedInstance];
    dispatch_group_enter(_blockTaskGroup);
    [client get:@"http://www.weather.com.cn/data/sk/101010100.html" inBackground:YES callback:^(id object) {
        NSLog(@"result:%@",object);

        NSLog(@"func1 block end......");
        dispatch_group_leave(_blockTaskGroup);
    }];
    NSLog(@"func1 end......");
}

- (void)func2:(BOOL)isRefresh{
    //...
    NSLog(@"func2 start......");
    Client *client = [Client sharedInstance];
    dispatch_group_enter(_blockTaskGroup);
    [client get:@"http://www.weather.com.cn/data/sk/101010100.html" inBackground:YES callback:^(id object) {
        NSLog(@"result:%@",object);

        NSLog(@"func2 block end......");
        dispatch_group_leave(_blockTaskGroup);
    }];
    NSLog(@"func2 end......");
}
{% endhighlight %}

{% highlight Objective-C %}

dispatch_group_t _blockTaskGroup;

...


if (!_blockTaskGroup) {
    _blockTaskGroup = dispatch_group_create();
}
[self func1:YES];
[self func2:YES];


dispatch_group_notify(_blockTaskGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSLog(@"finally!");
});
{% endhighlight %}

我们再看一下运行结果：  
![image]({{ site.attachment }}/posts/2016-02-06-blockgroup_4.png)    

其实就是利用Dispatch Groups手动管理block的特性。需要注意的是：
>  dispatch_group_enter 必须要与 dispatch_group_leave 一一对应，如果缺少了dispatch_group_leave，则这个block将永远在group中无法结束。


与dispatch_group_notify类似的是还有一个dispatch_group_wait,是同步的，即调用的线程会阻塞，知道所有的group任务结束才会继续执行。













