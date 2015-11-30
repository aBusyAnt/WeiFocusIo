---
layout: post
title: "Core Graphics"
description: ""
category: 'Core Graphics'
tags: ['Core Graphics']
---
{% include JB/setup %}

Core Graphics 是iOS上层UIKit实现的基础，为了更好的了解iOS的绘制体系，学习Core Graphics很有必要。自定义控件也都基于Core Graphics，所以要想在iOS开发中进行更高级的开发，必然要了解Core Graphics。

<!--more-->

![image]({{ site.attachment }}/posts/2015-11-30-coregraphics-img1.png)   

但是我们在实际的开发过程中经常看到Core Graphics与Quartz混合使用，这二者到底是什么关系？

> iOS Developer Library中有很清晰的说明：     
> The Quartz 2D API is part of the Core Graphics framework, so you may see Quartz referred to as Core Graphics or, simply, CG.    
> Core Graphics是一套用C写的、非面向对象的API，而Quzrtz是其一部分，是Core Graphics进行2D绘制的引擎。  

绘制的基本步骤:   

> 获得绘制上下文 -> 创建路径并添加到上下文 -> 画笔移动到相应的绘制位置 ->设置画笔属性  -> 绘制 -> 释放创建的路径

绘制的方式一般分为三种：

* 直接按顺序一步一步画
* 利用CGPath
* 利用UIBezierPath


# 基本示例 :
{% highlight Objective-C %}
- (void)basicDrawRect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //红色矩形
    CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
    CGContextFillRect(ctx, CGRectMake(0, 0, 200, 100));
    //蓝色矩形
    CGContextSetRGBFillColor(ctx, 0, 0, 1, 0.5);//半透明
    CGContextFillRect(ctx, CGRectMake(0, 0, 100, 200));
}
{% endhighlight %}  
以上简单的几行代码，我们就画了2个部分重叠的矩形，Core Graphics还提供了一些常用的形状绘制方法,CGContextAdd...:

![image]({{ site.attachment }}/posts/2015-11-30-coregraphics-img4.png)   

我们使用这种方式来试一下,实现了同样的效果:  

{% highlight Objective-C %}
- (void)basicDrawRect2{
#define COLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextAddRect(ctx, CGRectMake(0, 0, 200, 100));
    CGContextSetFillColorWithColor(ctx, COLOR(255, 0, 0, 1).CGColor);
    CGContextFillPath(ctx);

    CGContextAddRect(ctx, CGRectMake(0, 0, 100, 200));
    CGContextSetFillColorWithColor(ctx, COLOR(0, 0, 255, 0.5).CGColor);
    CGContextFillPath(ctx);
}
{% endhighlight %}  

# Path 
Core Graphics绘制的设计原理跟人们绘画道理是一样的，用画笔在画布上不同的位置绘制相应的点、线、面。所以我们要绘制一条折线，那我们就要不断的移动画笔的在不同的起点与终点之间勾勒。
{% highlight Objective-C %}
- (void)linesDraw{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 220,220);
    CGPathAddLineToPoint(path, nil, 300,300);
    CGPathAddLineToPoint(path, nil, 200, 400);
    CGContextAddPath(ctx, path);
    
    CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1);//笔触色:红色
    CGContextSetRGBFillColor(ctx, 0, 0, 1, 1);//填充色:蓝色
    CGContextSetLineWidth(ctx, 2);//线条宽度
    CGContextSetLineCap(ctx, kCGLineCapRound);//线条头样式
    CGContextSetLineJoin(ctx, kCGLineJoinRound);//线条连接点样式
    
    CGContextDrawPath(ctx, kCGPathFillStroke);

    CGPathRelease(path);
}
{% endhighlight %}  

效果如下:
![image]({{ site.attachment }}/posts/2015-11-30-coregraphics-img5.png)   

# 曲线绘制  
曲线绘制是利用贝塞尔曲线的知识，利用控制点进行的，详情的使用请参考[Drawing and Printing Guide for iOS](https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010156)  。

![image]({{ site.attachment }}/posts/2015-11-30-coregraphics-img6.png)   

{% highlight Objective-C %}
- (void)curveDraw{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, 10, 10);
    CGContextAddCurveToPoint(ctx, 300, 300, 150, 150, 20, 400);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextSetLineWidth(ctx, 3);
    CGContextStrokePath(ctx);
}
{% endhighlight %}  
效果图:  
![image]({{ site.attachment }}/posts/2015-11-30-coregraphics-img7.png)   


# 综合实例:三毛
上面简单的示例我们就了解了Core Graphics绘制的大体流程，接下来，我们实现一个较为复杂的示例:绘制一个三毛。

{% highlight Objective-C %}
- (void)threeHairDraw{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //step 1:绘制圆形脸蛋
    //绘制椭圆前，先要指定其所在矩形区域
    CGContextAddEllipseInRect(ctx, CGRectMake(100, 100, 200, 200));
    //填充色
    CGContextSetFillColorWithColor(ctx, [UIColor orangeColor].CGColor);
    CGContextFillPath(ctx);
    
    
    //step2:画眼睛
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    //左眼
    //画圆有多种方法，这是用画一条曲线的方式，可以使用上面的矩形方式
    CGContextAddArc(ctx, 150, 150, 10, 0, 2*M_PI, 1);
    CGContextFillPath(ctx);
    //右眼
    CGContextAddArc(ctx, 300-50, 150, 10, 0, 2*M_PI, 1);
    CGContextFillPath(ctx);
    
    //step3:画鼻子
    CGContextSetFillColorWithColor(ctx, [UIColor purpleColor].CGColor);
    CGContextMoveToPoint(ctx, 200, 200);
    CGContextAddLineToPoint(ctx, 220,220);
    CGContextAddLineToPoint(ctx, 180, 220);
    CGContextAddLineToPoint(ctx, 200, 200);
    CGContextFillPath(ctx);
    
     //step 4:画嘴巴
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextAddRect(ctx, CGRectMake(170, 260, 60, 10));
    CGContextFillPath(ctx);
 
    //step 5:画三毛
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 3);
    
    CGContextMoveToPoint(ctx, 200, 100);
    CGContextAddCurveToPoint(ctx, 180, 80, 220, 60, 180, 30);

    CGContextMoveToPoint(ctx, 200, 100);
    CGContextAddCurveToPoint(ctx, 220, 80, 180, 60, 200, 30);

    CGContextMoveToPoint(ctx, 200, 100);
    CGContextAddCurveToPoint(ctx, 240, 80, 160, 60, 200, 30);

    CGContextStrokePath(ctx);
}
{% endhighlight %}  

效果图：   
![image]({{ site.attachment }}/posts/2015-11-30-coregraphics-img8.png)   

# UIBezierPath
前面使用了2种方式来实现了基本的绘制，现在我们一起来看一下UIBezierPath，UIBezierPath是对CGPath的上层封装，它以UI开头而不是CG开头，明显是上层UIKit层的API了，我们看一下利用上层的API如何进行绘制。
{% highlight Objective-C %}
- (void)bezierDraw{   
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(100.0, 0.0)];
    
    // Draw the lines.
    [aPath addLineToPoint:CGPointMake(200.0, 40.0)];
    [aPath addLineToPoint:CGPointMake(160, 140)];
    [aPath addLineToPoint:CGPointMake(40.0, 140)];
    [aPath addLineToPoint:CGPointMake(0.0, 40.0)];
    //勾勒还是填充stroke or fill
    [aPath stroke];
    [aPath closePath];
    
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(300, 300) radius:30 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [[UIColor redColor] setFill];
    [arcPath fill];
}

{% endhighlight %}  

效果图：   
![image]({{ site.attachment }}/posts/2015-11-30-coregraphics-img8.png)   
其它关于UIBezierPath更高级的功能请参考 [Drawing and Printing Guide for iOS](https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010156)  ，[iOS绘图教程](http://www.cnblogs.com/xdream86/archive/2012/12/12/2814552.html)


参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！   

 > * [Drawing and Printing Guide for iOS](https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010156)  
 > * [Quartz 2D Programming Guide](https://developer.apple.com/library/prerelease/ios/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007533-SW1)  
 > * [Core Graphics Tutorial: Lines, Rectangles, and Gradients](http://www.raywenderlich.com/32283/core-graphics-tutorial-lines-rectangles-and-gradients)  
 > * [Core Graphics Tutorial: Arcs and Paths](http://www.raywenderlich.com/33193/core-graphics-tutorial-arcs-and-paths)  
 > * [iOS绘图教程](http://www.cnblogs.com/xdream86/archive/2012/12/12/2814552.html)
