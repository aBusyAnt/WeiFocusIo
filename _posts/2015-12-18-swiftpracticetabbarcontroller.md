---
layout: post
title: "Cocoa-Swift实战-UITabBarController相关"
description: ""
category:'Cocoa Practice With Swift' 
tags: ['Cocoa Practice With Swift']
---
{% include JB/setup %}

Tabbar是最常见的一种布局结构，这种结构有一个最大的好处就是可以很方便地容纳非常多的模块，每个Tab就是一个抽屉，每个抽屉都是并列独立的，每个抽屉中又可以像递归一样不断的一层一层的添加子视图。
我们现在就来试一下，掌握其基本使用。

<!--more-->
# 一、基本使用:  

1、一般UITabBarController是APP的基本结构，所以我们添加此基本结构一般2种方式:  
+ 如果使用代码可以在AppDelegate中实例化UITabBarController,并指定为window的rootViewController。  
+ 你IB中直接拉出UITabBarController,然后分别设置、添加 或者删除viewControllers的成员。  

为了更好的演示，我们这里全使用代码来操作,eg：    
{% highlight swift %}  
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let tabBarController = UITabBarController()
        
        //tab1
        let tab1RootVc = UINavigationController(rootViewController: Tab1ViewController())
        let tab1Item = UITabBarItem(title: "Tab1", image: nil, tag: 0)
        tab1RootVc.tabBarItem = tab1Item
        
        //tab2
        let tab2RootVc = UINavigationController(rootViewController: Tab2ViewController())
        let tab2Item = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.TopRated, tag: 1);
        tab2RootVc.tabBarItem = tab2Item
        
        tabBarController.viewControllers = Array(arrayLiteral: tab1RootVc,tab2RootVc)
        
        self.window!.rootViewController = tabBarController
        
        return true
    }
{% endhighlight %}  

UITabBarController有几个基本属性：
+ viewControllers ： 即UITabBarController的平行抽屉容器。  
+ selectedIndex : 当前选中的容器序号。  
+ selectedViewController : 当前选中的容器。  
+ tabBar : 可以通过tabBar获取，此属性仅仅是提供给UIActionSheet 的 showFromTabBar: 使用。  
> // Provided for -[UIActionSheet showFromTabBar:]. Attempting to modify the contents of the tab bar directly will throw an exception.

+ moreNavigationController:  只读，这个属性始终会返回一个有效的More navigation Controller，这个属性是系统自动添加的，而且在viewControllers中也是找不到的，当屏幕尺寸无法显示全部的TabbarItem时，则会把无法显示的添加到此More item中。
+ customizableViewControllers : 即运行时，可以调整Tabbar的先后顺序。  

还有几个扩展:  
+ tabBarItem: UITabBarItem! 
+ tabBarController: UITabBarController? { get }

UITabBarItem :
实例化方法，不解释:
{% highlight swift %}  
public convenience init(title: String?, image: UIImage?, tag: Int)
@available(iOS 7.0, *)
public convenience init(title: String?, image: UIImage?, selectedImage: UIImage?)
public convenience init(tabBarSystemItem systemItem: UITabBarSystemItem, tag: Int)
{% endhighlight %}  


# 修改UITabBarController样式:   
在修改其样式前，我们先看一下其UITabBar的定义中与颜色、背景图片、样式等外观相关的定义:    
{% highlight swift %}  
public class UITabBar : UIView {
	...	
    public var tintColor: UIColor!
    public var barTintColor: UIColor? // default is nil

    public var selectedImageTintColor: UIColor?
    public var backgroundImage: UIImage?
    public var selectionIndicatorImage: UIImage?

    public var shadowImage: UIImage?

    public var barStyle: UIBarStyle

    public var translucent: Bool

    ...
}
{% endhighlight %}  

+ 修改背景色 以下有3种方式可以修改 :   

1、像如下这样直接修改是无效的:     
{% highlight swift %}  
tabBarController.tabBar.backgroundColor = UIColor.greenColor()
{% endhighlight %}  

2、修改barTintColor可修改背景色:     
{% highlight swift %}  
tabBarController.tabBar.barTintColor = UIColor.redColor()
{% endhighlight %}  

3、可在tabBar上添加一个子view，并设置其在视图中的前台顺序，以作为背景色，这种方式在老版的iOS中，很多人都这样做，屡试不爽^_^    
{% highlight swift %}  
let tabBarSize = tabBarController.tabBar.bounds.size
let bgView = UIView(frame: CGRect(x: 0, y: 0, width:tabBarSize.width  , height: tabBarSize.height))
bgView.backgroundColor = UIColor.greenColor()
tabBarController.tabBar.insertSubview(bgView, atIndex: 1)
{% endhighlight %}  

4、制作颜色图片作为背景:  
虽然UITabBar的定义并未提供backgoundColor修改方法，但是却提供了backgroundImage修改方法，所以我们可以制作一个9像素的小方块图片，然后使用resizableImageWithCapInsets制作一个背景图片。  
{% highlight swift %}  
let bgImage = UIImage(named: "tabBarBgImage")?.resizableImageWithCapInsets(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
tabBarController.tabBar.backgroundImage = bgImage;
{% endhighlight %}  

+ 修改选中item的title、图片 渲染的前景色:    
{% highlight swift %}  
tabBarController.tabBar.tintColor = UIColor.greenColor()
{% endhighlight %}  

+ 修改item图片的渲染模式，eg，使用原图:   
{% highlight swift %}  
for vc in tabBarController.viewControllers!{
    vc.tabBarItem.image = vc.tabBarItem.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    vc.tabBarItem.selectedImage = vc.tabBarItem.selectedImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
}
{% endhighlight %}  

+ 修改tabBar的样式:  
先设置translucent透明度为false，即可很清晰的看到样式变化的效果，如果translucent为true（默认为true），则tabBar的背景色自然就与当前选中的VC的背景色相关了。
当translucent为true时，tabBar相当于设置barTintColor为当前选中的VC的背景色，并设置tabBar的透明度。

> PS: 可以设置样式为Default，Black。如果设置了barTintColor、backgroundImage，或者插入UIView作为背景都将影响样式，样式自然就无效了。

+ 阴影图片shadowImage：  
tabBar上部有一个默认的阴影,我们可以修改:   
{% highlight swift %}    
let bgImage = UIImage(named: "tabBarBgImage")?.resizableImageWithCapInsets(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
tabBarController.tabBar.backgroundImage = bgImage

tabBarController.tabBar.shadowImage = UIImage(named: "tabBarBgShawImage")
{% endhighlight %}  

![image]({{ site.attachment }}/posts/2015-12-18-_swift_practice_tabbarcontroller-img1.png)

+ tabBar选中的item背景标示图片,selectionIndicatorImage:   
此背景图片置于tabBar之上与barItemIcon之下。    
{% highlight Swift %}    
tabBarController.tabBar.shadowImage = UIImage(named: "tabBarBgShawImage")
{% endhighlight %}  

+ 修改item的位置、尺寸:    
要修改item位置、尺寸首先设置items的布局模式，如fill,center。
我们要想体现出item的宽度、间距的变化，就需要先设置:     
{% highlight swift %}    
tabBarController.tabBar.itemPositioning = UITabBarItemPositioning.Centered

tabBarController.tabBar.itemSpacing = 20
tabBarController.tabBar.itemWidth  = 20
{% endhighlight %}  

![image]({{ site.attachment }}/posts/2015-12-18-_swift_practice_tabbarcontroller-img2.png)











