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


* singleton shared session：   
> 这种模式下不需要session configuration，是一个全局的基本讲求，使用全局的session,cookie,cache.    

* Default sessions:  
> 这种模式与shared session模式很类似，只是可以设置其session configuration，这种默认的方式使用磁盘存储缓存数据。  

* Ephemeral sessions:  
> 临时session配置，这种方式与default session配置的不同是，这种临时模式下缓存数据是存储在内存中的，程序退出后自然就会销毁。  

* Background sessions:  
> 后台session配置，这种方式与default session模式一样，只是会在后台开一个线程处理网络请求，所以这种方式一般用于文件的下载上传等。  

Session实例方式：

{% highlight Objective-C %}
/*
 * The shared session uses the currently set global NSURLCache,
 * NSHTTPCookieStorage and NSURLCredentialStorage objects.
 */
+ (NSURLSession *)sharedSession;

/*
 * Customization of NSURLSession occurs during creation of a new session.
 * If you only need to use the convenience routines with custom
 * configuration options it is not necessary to specify a delegate.
 * If you do specify a delegate, the delegate will be retained until after
 * the delegate has been sent the URLSession:didBecomeInvalidWithError: message.
 */
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue;
{% endhighlight %}  

> PS:其中第3种方式可以设置会话委托和所处的队列。


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

/*
 * An NSURLSessionDataTask does not provide any additional
 * functionality over an NSURLSessionTask and its presence is merely
 * to provide lexical differentiation from download and upload tasks.
 */
@interface NSURLSessionDataTask : NSURLSessionTask
@end

/*
 * An NSURLSessionUploadTask does not currently provide any additional
 * functionality over an NSURLSessionDataTask.  All delegate messages
 * that may be sent referencing an NSURLSessionDataTask equally apply
 * to NSURLSessionUploadTasks.
 */
@interface NSURLSessionUploadTask : NSURLSessionDataTask
@end

/*
 * NSURLSessionDownloadTask is a task that represents a download to
 * local storage.
 */
@interface NSURLSessionDownloadTask : NSURLSessionTask
{% endhighlight %}  

我们看一下NSURLSessionTask的创建：
1. 数据获取：  
{% highlight Objective-C %}
/*
 * data task convenience methods.  These methods create tasks that
 * bypass the normal delegate calls for response and data delivery,
 * and provide a simple cancelable asynchronous interface to receiving
 * data.  Errors will be returned in the NSURLErrorDomain, 
 * see <Foundation/NSURLError.h>.  The delegate, if any, will still be
 * called for authentication challenges.
 */
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

 
 
 
{% highlight Objective-C %}
 //仅以iOS9为示例，以前的很多方法都deprecated了。
    NSString *urlStr = @"http://www.weather.com.cn/data/sk/101010100.html";
    NSString *encodeUrlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrlStr]];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSLog(@"errorInfo:[%ld]",(long)error.code);
        dispatch_async(dispatch_get_main_queue(),^{
            _textView.text = [[NSString  alloc]initWithData:data encoding:NSUTF8StringEncoding];
        });
    }]resume];
{% endhighlight %}  





http://www.cocoachina.com/industry/20131106/7304.html


 







