---
layout: post
title: "Cocoa-Swift之UIViewController布局Tips"
description: ""
category: 'Cocoa-Swift'
tags: ['Cocoa-Swift']
---
{% include JB/setup %}
本文是UIViewController布局的一些注意事项与技巧。  

<!--more-->

# topLayoutGuide & bottomLayoutGuide  

先了解一下UIViewController的2个默认约束:  
{% highlight swift %}  
extension UIViewController {
    // These objects may be used as layout items in the NSLayoutConstraint API
    @available(iOS 7.0, *)
    public var topLayoutGuide: UILayoutSupport { get }
    @available(iOS 7.0, *)
    public var bottomLayoutGuide: UILayoutSupport { get }
}
{% endhighlight %} 
iOS7以后，ViewController的root view全屏了，所以Status Bar将会覆盖在其上，而同时apple也提供了以上2个扩展属性:  

* topLayoutGuide表示Y轴的最高点限制，表示不希望被Status Bar或Navigation Bar遮挡的视图最高位置。    

1、如果没有状态栏，也没有导航栏，topLayoutGuide.length则为0  
2、如果只Status Bar，则topLayoutGuide.length为状态栏高度，目前为20。    
3、如果只有Navigation Bar，则topLayoutGuide.length为导航栏高度，目前为44。   
4、如果二者都有，则topLayoutGuide.length为二者的高度，目前为20+44=64。  

我们做个实验即可得到上面的的结果:  
1、我们创建一个无状态栏时的ViewController：     
{% highlight swift %}  
print("self.topLayoutGuide.length:",self.topLayoutGuide.length)
{% endhighlight %} 
结果：  
{% highlight swift %}  
self.topLayoutGuide.length: 0.0    
{% endhighlight %} 
2、创建一个有状态栏时的ViewController：  
结果：  
{% highlight swift %}  
self.topLayoutGuide.length: 20.0   
{% endhighlight %} 
3、创建一个有状态栏，并将ViewController加入UINavigationController导航栈:  
结果：  
{% highlight swift %}  
self.topLayoutGuide.length: 64.0   
{% endhighlight %} 
4、无状态栏时，只有导航栏时:  
结果：  
{% highlight swift %}  
self.topLayoutGuide.length: 44.0   
{% endhighlight %} 

* bottomLayoutGuide表示Y轴的最低点限制，表示不希望被UITabbarController遮挡的视图最低点距离supviewlayout的距离。

即当无UITabbarController时，距离为0，有UITabbarController时距离为49:  

我们同样可以根据类似的实验，得到bottomLayoutGuide在UITabbarController的影响下的结果:  
无UITabbarController时，为0，有时为49.0:  
我们在AppDelegate中添加:  
{% highlight swift %}   
let tabBarController = UITabBarController()
tabBarController.viewControllers = Array(arrayLiteral: ViewController())
self.window?.rootViewController = tabBarController
{% endhighlight %} 
在ViewController中添加debug信息:   
{% highlight swift %}   
print("self.bottomLayoutGuide.length:",self.bottomLayoutGuide.length)
{% endhighlight %}   
结果：  
{% highlight swift %}   
self.bottomLayoutGuide.length: 49.0   
{% endhighlight %}   


# frame & bounds  

* frame没有什么好讲的，就是相对于父视图的布局位置与大小:  

> 比如一个view的 frame = CGRect(x:view.frame.origin.x,y:view.frame.origin.y,view.frame.size.width,view.frame.size.height)

* bounds与frame最大的不同就是坐标系不同，bounds原点始终是(0,0)，而frame的原点则不一定，而是相对于其父视图的坐标。     
二者的区别如下图所示:    
![image]({{ site.attachment }}/posts/2015-12-19-swiftpracticeviewcontrollerbaselayout-img1.jpg)





