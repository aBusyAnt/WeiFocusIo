---
layout: post
title: "AutoLayout深入浅出四[不仅是UIWebView与UITableView的纠缠]"
description: ""
category: 'AutoLayout'
tags: ['AutoLayout']
---
{% include JB/setup %}

上一篇中我们已经深度使用了Autolayout，UIScrollView是一个比较复杂的控件了，我用了一个较为复杂也比较觉见的布局示例将Autolayout在Scrollview下的应用讨论了一遍，希望有帮助到你更好的理解Autolayout，或者代码的部分内容可以给你一些启示。
而我们现在一起来看一下UIWebView在UITableView中应用会遇到什么问题，以及如何来解。

<!--more-->

由于iOS SDK只给我们提供了一个UIWebView用来渲染展示web内容，它是一个五脏俱全小型Safari,它的笨重是可想而知的，需要UIWebKit框架。
一般开发人员都会尽力避免跟UIWebView纠缠，因为它是一个内存消耗大户，由于加载的网页内容可能会涉及到大量js,css,图片，其中有些图片的尺寸可真不是盖的，会让APP的内存消耗陡增，进而让系统被迫杀死你心爱的APP。

很多富文本排版使用TextCore非常局限，使用起来比较麻烦，特别是图文混排，要处理很多绘制的细节，工作量比较大。在UITextKit出来之前有很多图文混排都是由WebView来简单的承担，所以我们对于这一对组合的场景也必须掌握。

我们另一个内存消耗大户是UITableView,UITableView可以说基本上是每一个APP都不可能离开的控件，它极大的简化了列表的功能使用。得益于UITableView的Reuse机制，我们将布局类似的Cell进行重用，改变展示的内容即可，进而大大减少了UITableView消耗的内存。

在这里顺带提醒一下，Reuse机制是用于UITableView的类似Cell的重用，对于相差很大的Cell,可以分开建立多个重用Cell,而不要因为不同的Cell混在TableView里面而带来的行高与更新问题而盲目的删掉重用机制。
比如,经常看到一些初学者在各个论坛提问UITableViewCell重叠的问题，让人遗憾的是，有很多做了几年iOS开发的"老鸟"给的意见是下面这种：

{% highlight Objective-C %}
for(id subview in cell.contentView.subviews){
    [subview removeFromSuperview];
}
{% endhighlight %}
也就是直接把UITableViewCell的重用机制关闭了，每一行都要重新构建，得到的结果就是UTableView滑动变得非常的卡，效率很低。

好了，回到正题，我们把UIWebView加到cell.contentView上面的目的肯定都是想让WebView的内容显示完全，也就是WebView的ContentSize.height并不等于这一行UITableViewCell的高，怎么办？

可能你会在UIWebView的加载完成的Delegate webViewDidFinishLoad 中重新刷新UITableView,但是你很快就会发现 死循环了。
其实思考方向并没有错，我们一般的流程:  

> * 请求数据 -> 加载UITableView ->加载UIWebView ->重新计算并调整UIWebView及其行高。

流程是这样，应该没有错，但是如何在webview加载完成过后重新计算webview高度，调整tableview行高呢？

我们可以添加一个变量webviewHeight，给一个初始值，当webview加载完成过后，再更新webviewHeight的值，然后判断webviewHeight如果等于初始值就刷新这一行。

{% highlight Objective-C %}

//CustomCell
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	_webviewIsLoading = webView.loading

	CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
	CGRect frame = webView.frame;
	frame.size.height = height;
	webView.frame = frame;
	if(_webViewLoadFinished){
		_webViewLoadFinished(frame.size.height);
	}
}
//VC
#define kFirstRequestUrlString @"http://news.baidu.com"

cell.webViewLoadFinished = ^(CGFloat height){
	if (_webviewHeight != height) {
        _htmlHeight = frame.size.height;
        [_iTableView beginUpdates];
        [_iTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_iTableView endUpdates];
    }
};

{% endhighlight %}

这样似乎可以避免死循环，但是你可能已经意识到了当webview加载完成过后，webview还会再去请求一次，因为第一次加载完成过后，判断height不等于_webviewHeight，webview就会刷新这一行，webview自然就会重新请求，由于webview的内容一般比较复杂，很有可能会有大量图片，如果多一次加载，就有可能多上M的流量，这显然不是我们能够容忍的。

幸好UIWebview给我们提供了加载过滤的代理：

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType ;

问题又来了，如何判断是否该加载呢？一个Web里面很有非常多的css,js,img等的请求，同样还有可能会有重定向，这些都会导致webview的代理被调用。

如果以是否加载完成即webview.loading来判断，那如果有重定向能解决吗？

如果以第一个请求为判断确定是否是第二次刷新是否就对呢？

你不妨试一下！


{% highlight Objective-C %}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//这样行吗？
	if(_webviewIsLoading){
		return YES;
	}

	//这样行吗？
	#define kFirstRequestUrlString @"http://news.baidu.com"\
    NSString *url = request.URL.absoluteString;
    if(![url isEqualToString:kFirstRequestUrlString]){
    	return YES;
    }
	//这样是否OK呢？	
	
    return NO;
}

{% endhighlight %}

本文主要是给大家分析UIWebView与UITableView遇到一起过后会出现的问题，弄了一些小聪明来糊弄UITableView，我们知道UITableViewCell的高度是在画每一行之前就确定了的，就是说heightForRowAtIndexPath 是 在 cellForRowAtIndexPath 之前执行的，如果能够在每一行cellForRowAtIndexPath之前就确定height就成了问题的关键。

上面讲的这些内容其实与autolayout没有多大关系，iOS最初的版本就有了以上要讨论的内容。

到目前为止，我们还没有给出UITableView的高度的动态计算的一个比较全面、通用的方法，而这种需求又是非常常见的，那到底有没有什么方法可以一劳永逸的解决掉UITableView的高度问题呢？在技术上，特别是程序实现上，其实永远都是有答案的，所以一些初学者遇到一些常见问题过后，就会立即陷入开发的泥潭，要么绕圈子绕过去，要么就在泥潭面前束手无策，作为一个程序员，最大的能力不是代码写的有多好，而是其学习能力，因为技术永远是不可能学得完的，你总会有未知的东西，重点在于你有没有学习的方法去掌握需要掌握的东西，有没有学习的能力去把未知变成已知。


在下一篇[AutoLayout深入浅出五-UITableView动态高度全面解决]("{{ site.production_url}}/{{site.JB.BASE_PATH}}/autolayout/2015/02/01/autolayout5/")中，我们将专注于UITableView的高度如何进行动态计算，我写这些文章并不是要告诉你这个问题的答案是什么，而是告诉你，我们开发过程中如何思考的，遇到问题过后，如何解决的，也就是从实践中学习，掌握需要掌握的必要的原理与思维方式。



参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * [https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIWebView_Class/#//apple_ref/occ/instp/UIWebView/loading](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIWebView_Class/#//apple_ref/occ/instp/UIWebView/loading)    
> * [http://blog.jldagon.me/blog/2012/08/13/uiscrollception-embedding-multiple-uiwebviews-in-a-uitableview/](http://blog.jldagon.me/blog/2012/08/13/uiscrollception-embedding-multiple-uiwebviews-in-a-uitableview/)  










