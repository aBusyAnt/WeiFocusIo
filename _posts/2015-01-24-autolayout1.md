---
layout: post
title: "AutoLayout深入浅出[一]"
description: ""
category: "Object-C"
tags: ['AutoLayout']
---
{% include JB/setup %}

我想大部分的iOS开发者都面临着iOS设备分辨率碎片化而带来的一系列适配问题，以前的Rect布局方式显得越来越古板，越来越无法高效的完成我们布局的想法，不论是使用xib还是code进行布局都要无休止的使用分辨率进行调整，所有的布局完全相对于分辨率，新手一般会把布局写的比较死，而老手会把布局使用分辨率作为基点，但面对复杂的布局，总是感觉应该变革，为懒惰的程序员减少工作量，为其腾出更多时间来极客。这里我就和大家一起来把iOS的布局系统的研究下，一方面是为自己完善露点，另一方面也希望能够帮助到someone.
这里先来第一篇，引入AutoLayout。

<!--more-->
我们一起来回顾一下iphone的分辨率：

> * 3GS :	480x320 
> * 4(S) :	960x640
> * 5(S) :	1136x640
> * 6 :	1334x750
> * 6 Plus : 1920x1080

可以看到从2009年iphone3GS发布一直到2014年iphone plus发布，iphone的分辨率经历了各种变迁，在iphone6发布以前坚持了横向的宽度，这让我们这种开发者无需过多的
考虑适配问题，但android阵营的大屏手机来势汹汹，不断蚕食iphone的高端客户，为了迎合已经被"惯坏"的消费者的大屏需求，Apple也逐渐加快了大屏的投入，消费者满意了，但是开发者确会很苦逼，其实这些Apple看的很清楚，Apple是一家非常非常重视开发者的公司，iphone的成功归根结底不是长的好看，不是做工优良，而是有app store，而app store是由全球的iOS开发者贡献，Apple深知全球的iOS开发者是推动iphone保持热度的动力，为了使开发者能够更好的为iphone产业链做贡献，必然会为开发者提供自己能够提供的最好的工具，不得不说Apple的工程师们非常聪明，不断的创造新的理念，新的设计，在iphone设备间的适配方式也是Apple工程师们最急需为开发者解决的问题，现在我们就一起来看一下iOS布局方式的演变。

一、Rect

确定一个View的展现，需要一个原点和长宽，所以一开始的布局都是以此定律来写：  
{% highlight Objective-C %}
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    view.backgroundColor = [UIColor lightGrayColor];
    
    UIView *subView1 = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
    [view addSubview:subView1];
    
    [self.view addSubview:view];
{% endhighlight %}
但是我们希望view在高分辨率下能够变大，而低分辨率下变小，如何办？我们可能会这样：
{% highlight Objective-C %}
    CGFloat hMargin = 50;
    CGFloat vMargin = 100;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-hMargin, self.view.bounds.size.height-vMargin)];
    view.backgroundColor = [UIColor lightGrayColor];
    
    CGFloat subMargin  = 10;
    UIView *subView1 = [[UIView alloc]initWithFrame:CGRectMake(subMargin, subMargin, view.bounds.size.width-subMargin, view.bounds.size.height-subMargin)];
    [view addSubview:subView1];
    
    [self.view addSubview:view];
{% endhighlight %}
即将所有的view的frame都基于controller的root view的大小，而controller会根据分辨率自动确定其大小，所以我们添加在root view上的sub views都基于root view的大小进行相对布局，即一层一层的相对于父视图的大小，利用边界宽度，利用父视图的长宽来确定子视图的尺寸。
当多个并列的视图要同时添加到一个父视图时，我们可能会根据设计计算出各个视图的比例，确定边界，然后在添加view时利用计算出的比例将父视图的可见窗瓜分，这就像一块蛋糕，我们先要确定有多少人就可以确定有多少份，然后需要确定每一份的占比(蛋糕当然不需要算占比，just a simile)。
但是也有很多时候，很多的代码并不会按这样的思路一直写下去，这样一层一层的计算真的很累，而且需要设计师配合，这对懒惰的程序员不算是一个好的消息，于是我们可能会用autoresizingMask来解决：

二、autoresizingMask 
我们看一下如下代码的效果：
{% highlight Objective-C %}
UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width-10*2, 100)];
view.backgroundColor = [UIColor lightGrayColor];
[self.view addSubview:view];
{% endhighlight %}

<img src="{{ site.attachment }}/posts/2015-01-24-autolayout1_1.PNG" align="center" width="200" height="150">  
<img src="{{ site.attachment }}/posts/2015-01-24-autolayout1_2.PNG" align="center" width="200" height="150">  

运行,旋转，你会发现竖屏时，显示正常，但是横屏时你会发现宽度没变，距离右侧距离变大了, 此时有两种做法，要么在旋转事件中重新对视图进行布局调整，要么就使用autoresizingMask来解决，前者一想就知道工作量繁琐，容易出错，会花不小时间精力。我们肯定会选择后者。
我们添加一句：
{% highlight Objective-C %}
view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
{% endhighlight %}
<img src="{{ site.attachment }}/posts/2015-01-24-autolayout1_3.PNG" align="center" width="200" height="150">  
你会发现神奇的事情发生了，它横屏、竖屏时左右间距都对了，那什么是autoresizingMask呢？  
顾明思意，就是自动调整视图相对于父视图的位置大小，我们来看一下autoresizingMask的定义
{% highlight Objective-C %}
typedef NS_OPTIONS(NSUInteger, UIViewAutoresizing) {
    UIViewAutoresizingNone                 = 0,
    UIViewAutoresizingFlexibleLeftMargin   = 1 << 0,
    UIViewAutoresizingFlexibleWidth        = 1 << 1,
    UIViewAutoresizingFlexibleRightMargin  = 1 << 2,
    UIViewAutoresizingFlexibleTopMargin    = 1 << 3,
    UIViewAutoresizingFlexibleHeight       = 1 << 4,
    UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};
{% endhighlight %}

其中:

	UIViewAutoresizingNone 不会随父视图的改变而改变
	UIViewAutoresizingFlexibleLeftMargin 自动调整view与父视图左边距，以保证右边距不变
	UIViewAutoresizingFlexibleWidth 自动调整view的宽度，保证左边距和右边距不变
	UIViewAutoresizingFlexibleRightMargin 自动调整view与父视图右边距，以保证左边距不变
	UIViewAutoresizingFlexibleTopMargin 自动调整view与父视图上边距，以保证下边距不变
	UIViewAutoresizingFlexibleHeight 自动调整view的高度，以保证上边距和下边距不变
	UIViewAutoresizingFlexibleBottomMargin 自动调整view与父视图的下边距，以保证上边距不变

默认为UIViewAutoresizingNone,需要注意的是这个枚举定义的字面意思是调整的部分，比如UIViewAutoresizingFlexibleWidth调整的就是宽度，而不是说宽度不变化，这里描述的是变的部分，就跟汽车里面的ESP一样，有一个关的开关，按下去就表示关，所以需要注意。(提醒车友千万千万保持ESP处于开的状态，现代汽车就是这些电子器件保证了驾车的便捷与安全，它可以救你无数次)。  
autoresizingMask在使用时，其值并不限于定义的值，可以组合，如下保证上边距和左边距不变，view将自动调整与下边距与右边距。

[topView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];











