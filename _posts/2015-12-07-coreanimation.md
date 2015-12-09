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

# 基本理论  
![image]({{ site.attachment }}/posts/2015-12-07-coreanimation-img1.png) 

我们从宏观上去看Core Animation，它基于Core Graphics与OpenGL.   
Core Graphics的使用，请查看之前的文章：[Core Graphics](http://grayluo.github.io/WeiFocusIo/core%20graphics/2015/11/30/coregraphics/)  

在讲Core Animation之前，我们还是先来普及一下底层的Graphics hd：  

![image]({{ site.attachment }}/posts/2015-12-07-coreanimation-img3.png) 

图片显示在屏幕上，无非就是无数个像素点，也就是分辨率，也就是这么多个显示单元，而每个单元由RGB三色按不同比例与透明度混合而成，每秒更新N次进行刷新。  
CPU进行一般运算，而图象运算非常的复杂，在计算机体系发展过程中，为了追求更高效的图象处理，越来越多的主机独立出来了显卡，由显卡进行图象运算，当然现代的主机即便没有GPU，其实现在的CPU一般都会集成CPU运算模块，专门针对图象运算，但是当然还是会占用CPU资源，所以一般的都会采用独立的GPU来处理。  

CPU与GPU的配合是非常的复杂的，比如：CPU拿到绘制数据后 传递给GPU，GPU判断是否需要重新生成纹理，或者仅仅是调整坐标。  

更多底层的绘制原理可以查看文章:  

+ [Getting Pixels onto the Screen](https://www.objc.io/issues/3-views/moving-pixels-onto-the-screen/#pixels)->[译文:绘制像素到屏幕](http://blog.jobbole.com/54511/)  
+ [Core Animation Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html)->[官方文档中译:Core Animation编程指南](http://www.cocoachina.com/ios/20131230/7627.html) 

# UIView动画
UIView，可以产生动画的变化包括: 

+ 位置变化    
+ 大小变化     
+ 拉伸  
+ 旋转  
+ 透明度变化    
+ 显示或隐藏状态变化  
+ UIView图层顺序变化   

以下是一个最基本的动画示例:  
{% highlight Objective-C %}
- (void)uiviewAnimationTest{
//    UIView *contentView = [[UIView alloc]initWithFrame:CGRectZero];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *contentView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    contentView.backgroundColor = [UIColor redColor];
    contentView2.backgroundColor = [UIColor blueColor];

    [self.view addSubview:contentView];
    [self.view addSubview:contentView2];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //
    [UIView beginAnimations:@"uiviewAnimationTest" context:context];//动画开始
    //设置动画加减速方式
    /*
        UIViewAnimationCurveEaseInOut,         // slow at beginning and end
        UIViewAnimationCurveEaseIn,            // slow at beginning
        UIViewAnimationCurveEaseOut,           // slow at end
        UIViewAnimationCurveLinear
     */
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //动画时长，一般动画时长不要超过2s，以免用户厌恶
    [UIView setAnimationDuration:2.0];
    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDelegate:self];
    
    //默认的委托是-animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context,
    //当然也可以修改
    //[UIView setAnimationDidStopSelector:<#(nullable SEL)#>];
    
    //view开始动画的起始位置从当前位置还是默认位置，这对于连续的多个动画串连起来很有用，可以保证动画的连贯性。
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    [self.view bringSubviewToFront:contentView];
    //UIView改变的内容
//    contentView.backgroundColor = [UIColor redColor];
//    contentView.frame = CGRectMake(100, 100, 100, 100);
    
    //动画的过渡效果
    /*
    UIViewAnimationTransitionNone,
    UIViewAnimationTransitionFlipFromLeft,
    UIViewAnimationTransitionFlipFromRight,
    UIViewAnimationTransitionCurlUp,
    UIViewAnimationTransitionCurlDown,
*/
    
    
    [UIView commitAnimations];//动画结束
}

{% endhighlight %}  

动画完成的回调:  
{% highlight Objective-C %}
//setAnimationDidStopSelector默认的委托
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    NSLog(@"animationId:%@",animationID);
}
{% endhighlight %}  


# Core Animation   
在深入学习Core Animation之前我们先了解一下我们将使用的各个类的层次结构:  

CAAnimation类:  
![image]({{ site.attachment }}/posts/2015-12-07-coreanimation-img5.png) 

CALayer类:  
![image]({{ site.attachment }}/posts/2015-12-07-coreanimation-img6.png) 

Core Animation动画使用步骤:

+ 确定动画作用的图层CALayer    
+ 实例化CAAnimation对象    
+ 添加CAAnimation动画至CALayer上即可开始执行动画(addAnimation:forKey:)  
+ 从CALayer移除动画即可停止动画(removeAnimationForKey:)  

CAAnimation动画中改变layer的坐标在动画结束后会恢复，转场动画CATransition例外。

CAAnimation是动画抽象类，此类提供了CAMediaTiming与CAAction协议，实际动画相关的创建操作均由其子类实现:  
CABasicAnimation, CAKeyframeAnimation, CAAnimationGroup, 或者使用Apple一些封装好的转场动画CATransition.  

其中:  

* CAMediaTiming :    
{% highlight Objective-C %}
@protocol CAMediaTiming
@property CFTimeInterval beginTime;
@property CFTimeInterval duration;
@property float speed;
@property CFTimeInterval timeOffset;
@property float repeatCount;
@property CFTimeInterval repeatDuration;
@property BOOL autoreverses;//自动恢复动画执行前的CALayer状态
/*
kCAFillModeRemoved:动画产生的变化在动画执行前后都不影响CALayer.
kCAFillModeForwards:动画结束后保持动画对CALayer的影响。
kCAFillModeBackwards:动画开始执行前就进入动画的初始状态。
kCAFillModeBoth:前面两种同时生效
*/
@property(copy) NSString *fillMode;
@end
{% endhighlight %}  


* CAPropertyAnimation :
{% highlight Objective-C %}
@interface CAPropertyAnimation : CAAnimation
+ (instancetype)animationWithKeyPath:(nullable NSString *)path;
@property(nullable, copy) NSString *keyPath;
@property(getter=isAdditive) BOOL additive;
@property(getter=isCumulative) BOOL cumulative;
@property(nullable, strong) CAValueFunction *valueFunction;
@end
{% endhighlight %}  

CABasicAnimation动画类型支持:  
![image]({{ site.attachment }}/posts/2015-12-07-coreanimation-img6.png) 


* CABasicAnimation:  
如其名.基本动画类，继承自CAPropertyAnimation，通过设定起点、终点、时间等参数，动画会按设定的点与参数执行。    
{% highlight Objective-C %}
@interface CABasicAnimation : CAPropertyAnimation
@property(nullable, strong) id fromValue;//keyPath初始值
@property(nullable, strong) id toValue;//keyPath结束值
@property(nullable, strong) id byValue;
@end
{% endhighlight %}  

* CAKeyframeAnimation:  
关键帧动画，也如其名，就是可以设置动画执行的路径的关键点:  
{% highlight Objective-C %}
@interface CAKeyframeAnimation : CAPropertyAnimation

//与CABasicAnimation的fromValue,toValue意义一样，只是可以设置中间的值，而不仅仅是起点与终点.
@property(nullable, copy) NSArray *values;

//是另一种动画路径方式，只对CALayer的anchorPoint与position作用，设置path后，上面的value设置则被忽略。
@property(nullable) CGPathRef path;

//为关键帧指定对应执行的时间点，(0~1.0),若无设置keyTimes，则关键帧时间平分。
@property(nullable, copy) NSArray<NSNumber *> *keyTimes;

@property(nullable, copy) NSArray<CAMediaTimingFunction *> *timingFunctions;
@property(copy) NSString *calculationMode;
@property(nullable, copy) NSArray<NSNumber *> *tensionValues;
@property(nullable, copy) NSArray<NSNumber *> *continuityValues;
@property(nullable, copy) NSArray<NSNumber *> *biasValues;
@property(nullable, copy) NSString *rotationMode;
@end
{% endhighlight %}  

* CAAnimationGroup   
动画组，即多个动画可以加入Group后，将其添加到CALayer后并行执行。  

{% highlight Objective-C %}
@interface CAAnimationGroup : CAAnimation
@property(nullable, copy) NSArray<CAAnimation *> *animations;
@end
{% endhighlight %}  

* CATransition   
大家称之为转场动画，即提供移入、移出屏幕的动画.  

{% highlight Objective-C %}
@interface CATransition : CAAnimation
@property(copy) NSString *type;//动画类型
@property(nullable, copy) NSString *subtype;//动画方向
@property float startProgress;//动画过渡开始点
@property float endProgress;//动画过滤结束点
@property(nullable, strong) id filter;
@end
{% endhighlight %}  

# CALayer  :
CALayer主要用于内容的绘制与动画的实现，CALayer没有包含在UIKit层，并没有实现UIResponse,所以无法响应事件，一般我们在CoreAnimation中会有一个『显式动画』和『隐式动画』，显示动画就是直接给Layer图层添加动画，进行动画的实际设置操作，如设置相关的动画路径等，而隐式动画的意思就是直接对View的Layer属性修改从而产生的动画，意思就是说CALayer的某些支持隐式动画的属性的变动由系统添加类似CABasicAnimation的动画参数，但有一个例外，就是UIView的根Layer图层，它的属性修改并不产生动画，一般UIView一般作为CALayerDelegate，即CALayer的容器使用，创建系统创建UIView时会自动为其添加一个根图层，我们需要在这个根图层上添加子图层。

网友 KenshinCui把CALayer的属性列出来了，并列出了对隐式动画的支持属性，大家可以参考:   

![image]({{ site.attachment }}/posts/2015-12-07-coreanimation-img7.png) 

注意：  

+ 从上图中，我们可以看出只有frame与doubleSided不支持隐式动画。  
+ CALayer的透明度由opacity表示，而不像UIView使用alpha。  
+ position相当于View的center  
+ CALayer的坐标比View多了AnchorPoint，即锚点，确定layer图层上哪个点在postion，用于确定相对于图层position的位置,即相对于x,y轴的比例，取值(0~1,0~1)，默认值(0.5,0.5)，以layer图层左上角原点为anchorPoint计算的原点，以layer的长宽乘以anchorPoint的比例，如layer的frame为(10,10,100,200),anchorPoint为(0.3，0.3),则layer实际显示的中心点为(100*0.3,200*0.3)，即layer上的此点与postion重合。
可以想象layer在这个position点上面不断的左右移动，以确定layer上某个点与position重合，如果不是layer的中心点与其重合，则就会产生偏移。  


AnchorPoint的概念容易出问题，我们一起做个实验就可以更好的理解它了：  

*  layer的position为(50,50),anchorPoint为(0.5,0.5)，相当于x,y轴的50%,我们可以得到实际的layer显示的位置，即layer上与position重合的点为（100 x 0.5，100 x 0.5):   

<img src="{{ site.attachment }}/posts/2015-12-07-coreanimation-img8.png" width="1300" height="700"/>

*  layer的position还是为(50,50),但是，可以明显看到layer的中心点并非如打印的结果一样在(50,50)，anchorPoint为(0,0)，即layer上与position重合的点为（100 x 0，100 x 0):  

<img src="{{ site.attachment }}/posts/2015-12-07-coreanimation-img9.png" width="1300" height="700"/>


*  layer的position还是(50,50),但是，可以看到layer的中心点也并非如打印的结果一样在(50,50),anchorPoint为(1,1)，  即layer上与position重合的点为（100 x 1，100 x 1):  

<img src="{{ site.attachment }}/posts/2015-12-07-coreanimation-img10.png" width="1300" height="700"/>

# 基本动画、关键帧动画、动画组 实例:  

{% highlight Objective-C %}
//基本动画
- (void)coreAnimationTest{
    CALayer *layer = [[CALayer alloc]init];
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.frame = CGRectMake(10, 10, 100, 100);
    layer.cornerRadius = 2;
    [self.view.layer addSublayer:layer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:layer.position];
    
    //position移动
    CGPoint toPoint = layer.position;
    toPoint.x += 100;
    toPoint.y += 100;
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.duration = 5;
    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = YES;

    //以x轴进行旋转
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:6.0*M_PI];
    rotateAnimation.duration = 3;

    //长度缩放
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleAnimation.duration = 2;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:2.6];
    scaleAnimation.fillMode = kCAFillModeForwards;
    
    //
//    [layer addAnimation:animation forKey:@"animation"];
//    [layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
//    [layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 5;
    group.fillMode = kCAFillModeForwards;
    group.animations = [NSArray arrayWithObjects:animation,rotateAnimation,scaleAnimation, nil];
    [layer addAnimation:group forKey:@"group"];
}
//关键帧动画
- (IBAction)keyFrameAnimation:(id)sender {
    CALayer *layer = [[CALayer alloc]init];
    layer.frame = CGRectMake(40, 40, 40, 40);
//    layer.bounds = CGRectMake(40, 40, 40, 40);
    layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"twitter_bird_32px_577773_easyicon.net.png"].CGImage);
    [self.view.layer addSublayer:layer];
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    NSValue *key1 = [NSValue valueWithCGPoint:layer.position];
    NSValue *key2 = [NSValue valueWithCGPoint:CGPointMake(80,100)];
    NSValue *key3 = [NSValue valueWithCGPoint:CGPointMake(100,120)];
    NSValue *key4 = [NSValue valueWithCGPoint:CGPointMake(80,140)];
    NSValue *key5 = [NSValue valueWithCGPoint:CGPointMake(60,160)];
    NSValue *key6 = [NSValue valueWithCGPoint:CGPointMake(180,200)];
    
    keyFrameAnimation.duration = 5;
    keyFrameAnimation.beginTime = CACurrentMediaTime() + 2;
    
    keyFrameAnimation.values = @[key1,key2,key3,key4,key5,key6];
    
    [layer addAnimation:keyFrameAnimation forKey:@"keyFrameTest"];
    
}
{% endhighlight %}  

# 自定义绘制:  
我们在前面的Core Graphics中，讲了drawRect，自定义绘制就是在drawRect中绘制，其实CALayer也有类似的方法：drawInContext,其实我们前面已经说了UIView是CALayerDelegate,UIView的委托方法draw:inContext:,UIView会创建CALayer，并设置CALayer的委托为UIView，其实前面讲的drawRect方法也是在draw:inContext方法中调用的。CALayer将上下文传递给draw:inContent:,再由其传递给drawRect：，我们来创建一个自定义CAlayer图层。
{% highlight Objective-C %}
//GLCustomLayer.m
//-------------------------
#import "GLCustomLayer.h"
@implementation GLCustomLayer
- (void)drawInContext:(CGContextRef)ctx{
    NSLog(@"custom layer");
    
    CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
    CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
    
    CGContextMoveToPoint(ctx, 20, 20);
    CGContextAddLineToPoint(ctx,80, 20);
    CGContextAddLineToPoint(ctx,80, 80);
    CGContextAddLineToPoint(ctx,20, 80);
    CGContextAddLineToPoint(ctx,20, 20);

    CGContextDrawPath(ctx, kCGPathFillStroke);
    
}
@end

//GLCustomView.m
//-------------------------
#import "GLCustomView.h"
#import "GLCustomLayer.h"
@implementation GLCustomView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (id)initWithFrame:(CGRect)frame{
    NSLog(@"GLCustomView initWithFrame");
    if(self = [super initWithFrame:frame]){
        GLCustomLayer *layer = [[GLCustomLayer alloc]init];
        layer.bounds = CGRectMake(0, 0, 380, 380);
        layer.position = CGPointMake(190, 190);
        layer.backgroundColor = [UIColor blueColor].CGColor;
        
        [layer setNeedsDisplay];

        [self.layer addSublayer:layer];   
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    NSLog(@"GLCustomView drawRect");
    [super drawRect:rect];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    NSLog(@"GLCustomView drawLayer");
    [super drawLayer:layer inContext:ctx];
}


//Test
//-------------------------
- (void)customLayerTest{
    GLCustomView *customView = [[GLCustomView alloc]initWithFrame:CGRectMake(40, 40, 400, 400)];
    customView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:customView];
}

{% endhighlight %}  

# 转场动画实例:  

{% highlight Objective-C %}
- (void)transitionTestInit{
    _imgs = @[@"1.jpg",@"2.jpg",@"3.jpg"];
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 40, 400, 200)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = [UIImage imageNamed:@"0.jpg"];
    [self.view addSubview:_imageView];
    
    UISwipeGestureRecognizer *leftSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipeGesture.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGesture];
    
    UISwipeGestureRecognizer *rightSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
    rightSwipeGesture.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGesture];
}

-(void)leftSwipe:(UISwipeGestureRecognizer *)gesture{
    [self transitionText];
}

-(void)rightSwipe:(UISwipeGestureRecognizer *)gesture{
    [self transitionText];
}

- (void)transitionText{
    CATransition *transition = [[CATransition alloc]init];
    transition.type = @"cube";
    transition.subtype = kCATransitionFromLeft;
    transition.duration = 1.0f;
    
    _imageView.image = [self getImage];
    [_imageView.layer addAnimation:transition forKey:@"transitionAnimation"];
}
- (UIImage *)getImage{
    return [UIImage imageNamed:_imgs[arc4random() % _imgs.count]];
}
{% endhighlight %}  



小结：Core Animation还有很多高级应用，本篇仅仅是抛砖引玉，作为温习的笔记。





本文源代码:[GLCoreAnimation](https://github.com/GrayLuo/GLCoreAnimation)

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！   

 > * [Core Animation Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html)  
 > * [3D Graphics with OpenGL Basic Theory](http://www.ntu.edu.sg/home/ehchua/programming/opengl/CG_BasicsTheory.html#zz-1.)
 > * [Getting Pixels onto the Screen](https://www.objc.io/issues/3-views/moving-pixels-onto-the-screen/#pixels)
 > * [译文:绘制像素到屏幕](http://blog.jobbole.com/54511/)  
 > * [官方文档中译:Core Animation编程指南](http://www.cocoachina.com/ios/20131230/7627.html)
 > * [Core Animation基本概念和Additive Animation](http://studentdeng.github.io/blog/2014/06/24/core-animation/?utm_source=tuicool&utm_medium=referral)
 > * [CoreAnimation](http://www.jianshu.com/p/ee2d3a8b2d67)
 > * [View-Layer 协作](http://objccn.io/issue-12-4/)
 > * [Layer 中自定义属性的动画](http://objccn.io/issue-12-2/)
 > * [iOS核心动画](http://www.cnblogs.com/kenshincui/p/3972100.html)
