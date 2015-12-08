---
layout: post
title: "Core Animation"
description: ""
category: 'Core Animation'
tags: ['Core Animation']
---
{% include JB/setup %}

Core Animation使用率很高，我们要熟练使用Core Animation，就必须先了解Core Animation的实现原理。 虽然我们不求甚解，但基本的原理还是得了解一下吧。

<!--more-->

![image]({{ site.attachment }}/posts/2015-12-07-coreanimation-img1.png) 

我们从宏观上去看Core Animation，它基于Core Graphics与OpenGL. Core Graphics的使用，请查看之前的文章：[Core Graphics](http://grayluo.github.io/WeiFocusIo/core%20graphics/2015/11/30/coregraphics/)

在讲Core Animation之前，我们还是先来普及一下底层的Graphics hd：  

![image]({{ site.attachment }}/posts/2015-12-07-coreanimation-img3.png) 

图片显示在屏幕上，无非就是无数个像素点，也就是分辨率，也就是这么多个显示单元，而每个单元由RGB三色按不同比例与透明度混合而成，每秒更新N次进行刷新。  
CPU进行一般运算，而图象运算非常的复杂，在计算机体系发展过程中，为了追求更高的图象处理，越来越多的主机独立出来了显卡，由显卡进行图象运算，当然现代的主机即便没有GPU，其实现在的CPU一般都会集成CPU运算模块，专门针对图象运算，但是当然还是会占用CPU资源，所以一般的都会采用独立的GPU来处理。

CPU与GPU的配合是非常的复杂的，比如：CPU拿到绘制数据后 传递给GPU，GPU判断是否需要重新生成纹理，或者仅仅是调整坐标。  
更多的底层的绘制原理可以查看文章[Getting Pixels onto the Screen](https://www.objc.io/issues/3-views/moving-pixels-onto-the-screen/#pixels),[译文:绘制像素到屏幕](http://blog.jobbole.com/54511/)
还有官方文档都做了很详细的介绍，[Core Animation Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html) ,[官方文档中译:Core Animation编程指南](http://www.cocoachina.com/ios/20131230/7627.html) 




本文源代码:[GLCoreAnimation](https://github.com/GrayLuo/GLCoreAnimation)

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！   

 > * [Core Animation Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html)  
 > * [3D Graphics with OpenGL Basic Theory](http://www.ntu.edu.sg/home/ehchua/programming/opengl/CG_BasicsTheory.html#zz-1.)
 > * [Getting Pixels onto the Screen](https://www.objc.io/issues/3-views/moving-pixels-onto-the-screen/#pixels)
 > * [译文:绘制像素到屏幕](http://blog.jobbole.com/54511/)  
 > * [官方文档中译:Core Animation编程指南](http://www.cocoachina.com/ios/20131230/7627.html)

