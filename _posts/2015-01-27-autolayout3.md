---
layout: post
title: "AutoLayout深入浅出三[相遇Scrollview]"
description: ""
category: 'autolayout'
tags: ['autolayout']
---
{% include JB/setup %}

AutoLayout 与 UIScrollView的相遇是一个不可避免的场景,UITableView、UIWebView这些都是继承于UIScrollView的，而我们要讨论的也主要是其contentSize问题，所以就直接讲UIScrollView就OK了。

<!--more-->

![image]({{ site.attachment }}/posts/2015-01-27-autolayout3_1.png)

如上图，我们将view分为3个部分，上面一部分主要用于展示海报或者一些封面图片，中间部分用来展示一些基本的信息，比如商品页面的价格，销量，分类等比较重要的信息，下面用于展示一些额外的信息，比如推荐给用户的一些其它商品或者门店等信息。

我们先按之前讲的来添加一些contraints,看一下UIScrollView里面添加Constraints有什么区别没有。
先依次添加约束:  

	1.为上面的橙色view与UIImageview添加高度与上下左右的边距约束。
	2.然后再添加中间蓝色view及其内容的高度与上下左右边距的约束。
	3.再添加UISegment的高度与上下左右边距的约束。
	4.再添加底部的UITableView的上下左右边距约束。
	
好了，我们来看一下IB会怎么处理目前的约束：  

![image]({{ site.attachment }}/posts/2015-01-27-autolayout3_2.png)

My God ! 好多问题呀 @_@  
不要被问题给吓倒了，我们一坏了来看一下问题。
问题提示的是:  

>* Scroll View ,Need constraints for height   
>* Scrollable Content Size Ambiguity, Has ambiguous scrollable content height  
>* Missing Constraints, Need constraints for : width  
>* Scrollable Content Size Ambiguity,Has ambigous content size  

全是Scrollview的问题，而且意思基本上就是说IB无法确定ScrollView的宽度与高度，我们知道UIScrollView最重要的就是其contentSize的宽高了，如果这个无法确定，那scrollview就无法知晓可以滚动查看的区域。其实这仅仅是表象，IB不会因为contentSize的可见区域不确定而抱怨，因为它会有一个默认的可见区域就是其bounds,其实IB真正抱怨的是其内部的subViews的布局对于它的依赖，比如我们看最上面的橙色View相对于上、左、右的约束都相对于scrollview的。scrollview内部的subViews的约束全依赖于scrollview,这样子的话，问题就来了，Scrollview和UILabel、UIButton等这些控件一样都会根据内容调整其contentSize(autolayout布局模式中，UILabel这种控件都会根据内容对自身宽高进行调整),如果Scrollview要根据其subviews来调整自身的contentsize,而其subviews又要根据scrollview的contentsize调整自身的布局，是不是就矛盾了，就成了相互依赖了。

所以IB要求UIScrollview(当然包括继承于它的UITableview、UIWebview这些控件)的contentSize必须在布局时能够确定。

由于Scrollview的contentSize由其subviews确定，其subviews的布局依赖于其父视图Scrollview的边界。这个矛盾，要不解决前者问题，要不解决后者，即要么不让UIScrollView的contentSize由其subviews确定，要么就不让ScrollView的subviews不依赖其contentSize（即Scrollview的边界）。很显然，我们只能选择后者，因为前者你无法改变，其实从宏观上来看，改变了一个就相当于改变了两个，其实二者并没有什么特别区别，都是同一个问题导致的。

既然我们想好了策略，就来试一下，如何才能让Scrollview的subviews不依赖于其边界呢？
我们首先不考虑subviews的复杂布局情况，我们先把subviews嵌入到一个我们自己添加的ContainerViwe中，从而把我们的布局任务简化成Scrollview与ContainerView二者的约束关系，所有之前的subviews我们都放在ContainerView中，则subviews的约束就会仅仅依赖于ContainerView了，这些subviews不再与scrollview有直接关系。

我们虽然简化了布局任务，但是还是无法绕过Scrollview的ContentSize的边界确定问题，我们前面已经知道了Scrollview的子视图不能依赖于ScrollView的边界，那我们就让其子视图不依赖于其边界即可。
国外有一个网友在遇到上面的问题的时候就咨询了Apple的工程师，结果他们画了40分钟才给出了解决方案，这说明Scrollview在autolayout中的使用真的不是那么简单。Apple的工程师给出的解决方案就是让我们的ContainerView建立一个与UIScrollview的父视图即我们的main view建立一个Equal Width,Equal Height约束，这样子ContainerView的宽高就不再依赖于ScrollView的边界了，但是ContainerView还是Scrollview的子视图，Scrollview的边界还是没有确定，我们还要为ContainerView添加与ScrollView的边界约束，用以帮忙ScrollView确定边界。

![image]({{ site.attachment }}/posts/2015-01-27-autolayout3_3.png)

OK，我们建立了ContainerView与mainview的equal width与 equal height后，效果果然就是我们想要的。
关于Autolayout与Scrollview相遇的故事，我们就先讲到这里，关于布局的场景总是像国际象棋一样，有数不尽的步骤与结果，连Machine都可以为之苦恼，所以这里只是通过这么一个示例，让大家对autolayout的布局理念有一个更深入的认识，不要过多的去抓鱼，而要学会如何抓鱼，抓鱼的诀窍是什么，学习一门技术，大家都会有各自的体会与理解，从根本上去掌握技术的原理，以此来应对千变万化的场景才能事半功倍。

本文示例代码：[本文Demo](https://github.com/GrayLuo/ScrollViewAutoLayoutTest.git)

为了更好的理解autolayout的原理，推荐阅读：

Apple工程师如何讲解AutoLayout的？  
讲解视频地址：[Cocoa AutoLaout Video](https://developer.apple.com/videos/wwdc/2011/)，找名称为Cocoa Autolayout的那一个视频。

讲稿：[Cocoa autolayout PDF](https://developer.apple.com/devcenter/download.action?path=/wwdc_2011/adc_on_itunes__wwdc11_sessions__pdf/103_cocoa_autolayout.pdf)

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * http://natashatherobot.com/ios-autolayout-scrollview/
