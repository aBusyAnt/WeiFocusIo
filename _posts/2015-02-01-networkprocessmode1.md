---
layout: post
title: "iOS网络处理封装模式一[原汁原味]"
description: ""
category: 'Network Process'
tags: ['Network Process']
---
{% include JB/setup %}

本篇我们主要是一起来看一下IOS编程中网络模块中最常见的2种方式，底层的TCP和上层的HTTP，只有先了解最原始的东西，我们才会了解它的不足，才能知道从何入手进行改造。

<!--more-->
我们都知道网络编程中iso的7层结构：  
![image]({{ site.attachment }}/posts/2015-02-01-networkprocessmode1_img1.png)   

>    
  > * 物理层，即物理传输介质层。   
  > * 数据链路层，即数据分发时的处理，包括MAC寻址、数据校验、流量控制等多种功能。  
  > * 网络层，也就是所说的IP层，就是IP封包，路由等。  
  > * 传输层，常见的TCP/UDP就位于此层，就是位于IP包上层的数据封包层。   
  > * 会话层，就是负责回话的建立。    
  > * 表示层，用于数据的压缩，转换，比如由于不同的CPU架构（eg : mips vs arm）导致会有高低位问题，我们常见的网络传输时与2端的大小端转换问题。  
  > * 应用层，就是最上层的协议了，eg:http,ftp,ssh......  

为了方便大家理解数据封装的层次关系，我们再来看一下下面这个图：      
![image]({{ site.attachment }}/posts/2015-02-01-networkprocessmode1_img2.png)    
在我们开发普通的移动互联网程序时，一般都很少涉及到底层的应用，大部分应用都是基于http这种最上层的应用进行数据的交换的。当然在其它开发领域就需要关注的比较多了，比如嵌入式开发。    
我们看3种主要应用场景： 

* 第一种当然是最常见的http了，大部分的app都使用http+json进行数据交换，我就不用废话了。    
* 很多涉及到效率、安全、跨平台或者嵌入第三方库时，如果再用http显然不太合适，这个时候我们就得使用TCP/UDP了。  
* 第三种情况在APP中很少见，就是涉及的比较底层了，比如修改mac地址，修改mac工作模式，带宽等很多底层的参数，大都的目地是为了数据包的抓取。    

一、TCP/UDP
在iOS中进行TCP/UDP开发一般使用以下3种方式：
    
* BSD Socket ，请参考以下其它2篇文章：

> * [iOS网络编程[BSD Socket]](http://grayluo.github.io/WeiFocusIo/network%20process/2015/11/25/bsdsocket)
> * [iOS网络编程[完整地接受数据]](http://grayluo.github.io/WeiFocusIo/network%20process/2015/11/25/socketrecvdatacompletely)

* CFNetwork,apple的工程师的C封装，官方还提供了详细的编程指南：

>  [CFNetwork Programming Guide](https://developer.apple.com/library/mac/documentation/Networking/Conceptual/CFNetwork/CFStreamTasks/CFStreamTasks.html#//apple_ref/doc/uid/TP30001132-CH6-SW1)

* 第三方封装库，比如最著名的AsyncSocket。

二、HTTP  
WWDC2013中apple推出了NSURLSession，是对原来的NSURLConnection的重构，iOS9后已经完全废弃了NSURLConnection，而采用NSURLSession。  

1. 工作模式：  


* singleton shared session:    
 > 这种模式下不需要session configuration，是一个全局的基本讲求，使用全局的session,cookie,cache.    

* Default sessions:  
 > 这种模式与shared session模式很类似，只是可以设置其session configuration，这种默认的方式使用磁盘存储缓存数据。  

* Ephemeral sessions:    
 > 临时session配置，这种方式与default session配置的不同是，这种临时模式下缓存数据是存储在内存中的，程序退出后自然就会销毁。  

* Background sessions:   
 > 后台session配置，这种方式与default session模式一样，只是会在后台开一个线程处理网络请求，所以这种方式一般用于文件的下载上传等。  

NSURLSession创建实例方式：

{% highlight Objective-C %}

+ (NSURLSession *)sharedSession;

//由系统创建OperationQueue
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;

//可以设定delegate，且可以设定delegate回调所在的OperationQueue,
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue;

{% endhighlight %}  

> PS:其中第3种方式可以设置会话委托和所处的队列。

需要重点说明一下就是BackgroundSession的处理：  

*  当程序切换至后台过后，在BackgroundSession中的Task还会继续下载，Session将只能与ApplicationDelegate 和 Session中的Delegate交互。只有在后台时才能与ApplicationDelegate交互。

NSURLSessionDelegate的定义：

* -(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error;

//当实现了该delegate后，如果链接需要认证时，会回调此方法用于提供认证证书。
* - (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
                                             completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition
                                              disposition, NSURLCredential * __nullable credential))completionHandler;
                                              
//后台下载类型session的task 完成的delegate                                              
* - (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session NS_AVAILABLE_IOS(7_0);


2.会话配置： NSURLSessionConfiguration

{% highlight Objective-C %}
+ (NSURLSessionConfiguration *)defaultSessionConfiguration;

+ (NSURLSessionConfiguration *)ephemeralSessionConfiguration;

+ (NSURLSessionConfiguration *)backgroundSessionConfigurationWithIdentifier:(NSString *)identifier NS_AVAILABLE(10_10, 8_0);
{% endhighlight %}  

NSURLSessionConfiguration有很多属性，以下是几个常见的属性：  

> /* default cache policy for requests */  
> @property NSURLRequestCachePolicy requestCachePolicy;  

> /* default timeout for requests.  This will cause a timeout if no data is transmitted for the given timeout value, and is reset whenever data is transmitted. */  
> @property NSTimeInterval timeoutIntervalForRequest;  

> /* default timeout for requests.  This will cause a timeout if a resource is not able to be retrieved within a given timeout. */  
> @property NSTimeInterval timeoutIntervalForResource;  

> /* type of service for requests. */  
> @property NSURLRequestNetworkServiceType networkServiceType;  

> /* allow request to route over cellular. */  
> @property BOOL allowsCellularAccess;  

3. NSURLSessionTask 
从其定义中我们可以看到NSURLSessionTask的类结构:
{% highlight Objective-C %}

@interface NSURLSessionDataTask : NSURLSessionTask
@end
@interface NSURLSessionUploadTask : NSURLSessionDataTask
@end
@interface NSURLSessionDownloadTask : NSURLSessionTask
{% endhighlight %}  

我们看一下NSURLSessionTask的创建： 

1. 数据获取：    
{% highlight Objective-C %}
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler;
- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler;
{% endhighlight %}  

2.上传  
{% highlight Objective-C %}
/*
 * upload convenience method.
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler;  
{% endhighlight %}  

3. 下载    
{% highlight Objective-C %}
/*
 * download task convenience methods.  When a download successfully
 * completes, the NSURL will point to a file that must be read or
 * copied during the invocation of the completion routine.  The file
 * will be removed automatically.
 */
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL * __nullable location, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler;
- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * __nullable location, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler;
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData completionHandler:(void (^)(NSURL * __nullable location, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler;
{% endhighlight %}  

 
实战示例：   
1. 最简单的基本示例  
{% highlight Objective-C %}
NSString *urlStr = @"http://www.weather.com.cn/data/sk/101010100.html";
NSString *encodeUrlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrlStr]];
NSURLSession *session = [NSURLSession sharedSession];
[[session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSLog(@"errorInfo:[%ld]",(long)error.code);
        NSLog(@"result:%@",[[NSString  alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    }]resume];
{% endhighlight %}  


2. 使用NSURLSessionConfiguration的示例：
{% highlight Objective-C %}
NSString *urlStr = @"http://www.weather.com.cn/data/sk/101010100.html";
    NSString *encodeUrlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrlStr]];
    
#if TARGET_OS_IPHONE
    NSString *cachePath = @"/MyCacheDirectory";
    
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
    NSLog(@"Cache path: %@\n", fullCachePath);
#else
    NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/nsurlsessiondemo.cache"];
    
    NSLog(@"Cache path: %@\n", cachePath);
#endif
    
    NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity: 16384 diskCapacity: 268435456 diskPath: cachePath];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 10;
    sessionConfig.timeoutIntervalForResource = 5;
    sessionConfig.allowsCellularAccess = YES;
    
    sessionConfig.URLCache = myCache;
    sessionConfig.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;

    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSLog(@"errorInfo:[%ld]",(long)error.code);
        NSLog(@"result:%@",[[NSString  alloc]initWithData:data encoding:NSUTF8StringEncoding]);        
    }];
    [dataTask resume];
{% endhighlight %}  

若想使用更细的控制，可以用不Block,直接使用delegate
 
 {% highlight Objective-C %}
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
 {% endhighlight %}  


{% highlight Objective-C %}
#pragma mark NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"【1】DidReceiveResponse handle ");
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"DidReceiveData: %@",str);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if(error == nil)
    {
        NSLog(@"no error");
    }else{
        NSLog(@"Error %@",[error userInfo]);
    }
}
{% endhighlight %}  

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！   

 > * http://hayageek.com/ios-nsurlsession-example/
 > * http://www.cnblogs.com/biosli/p/iOS_Network_URL_Session.html
 > * https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html


 







