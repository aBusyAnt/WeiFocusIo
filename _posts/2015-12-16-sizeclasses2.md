---
layout: post
title: "Size Classes(二)[代码模式]"
description: ""
category: 'Size Classes'
tags: ['Size Classes']
---
{% include JB/setup %}

上一篇中，我们了解了Size Class的基本概念，但是在实际开发过程中，约束必然会根据实际的业务与数制进行调整，所以在代码中如何调整约束是我们不可回避的问题，比如某些信息在某种类别下显示，在某些类别下则不显示，然后不可能直接隐藏，而且后面或者下面的信息要相应的移动位置，所以在这些情况下就必然要动态调整约束。亦或是在不同的屏幕尺寸下可能各个控件间距，尺寸需要相应的调整。种种情况都要求开发者能够在代码中灵活的根据业务与设备进行最完美的适配。

<!--more-->

## 在代码中根据业务调整约束:    
不论是在IB中，还是如前面文章[AutoLayout深入浅出五[纯代码的偏执]](http://grayluo.github.io/WeiFocusIo/autolayout/2015/02/01/autolayout6)所述的代码中添加的约束，添加相应的引用IBOutlet，或者在代码中查找相应的约束，然后根据相应业务调整这些约束即可，比如隐藏，则可以调整高度或者宽度约束constant为0。   

> NSLayoutConstraint的属性大都是readonly,只有priority、shouldBeArchived、constant、active三个属性可以修改。

## 在代码中针对不同设备调整布局:    
{% highlight Objective-C %}
- (void)preferredContentSizeDidChangeForChildContentContainer:(id <UIContentContainer>)container NS_AVAILABLE_IOS(8_0);
- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(id <UIContentContainer>)container NS_AVAILABLE_IOS(8_0);
- (CGSize)sizeForChildContentContainer:(id <UIContentContainer>)container withParentContainerSize:(CGSize)parentSize NS_AVAILABLE_IOS(8_0);
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0);
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0);
{% endhighlight %}

以上是几个AutoLayout的委托代理，如果需要针对不同设备进行相应的布局调整我们可以像以下示例一样，获取当前布局类型属于9种中的哪一种，然后再调整在此类别下的布局。

{% highlight Objective-C %}
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular){
            //wCompact | hRegular
        }else if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact){
            //wCompact | hCompact
        }else if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassUnspecified){
            //wCompact | hAny
        }else if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular){
            //wRegular | hRegular
        }else if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact){
            //wRegular | hCompact
        }else if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassUnspecified){
            //wRegular | hAny
        }else if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassUnspecified && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular){
            //wAny | hRegular
        }else if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassUnspecified && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact){
            //wAny | hCompact
        }else if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassUnspecified && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassUnspecified){
            //wAny | hAny
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //
    }];
    [self.view setNeedsLayout];
}
{% endhighlight %}


