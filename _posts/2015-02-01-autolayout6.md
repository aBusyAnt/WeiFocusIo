---
layout: post
title: "AutoLayout深入浅出五[纯代码的偏执]"
description: ""
category: 'AutoLayout'
tags: ['AutoLayout']
---
{% include JB/setup %}

自定义View、根据数据动态调整布局等都是开发中很常见的需求，所以仅仅在IB中添加constraint不能应对所有的场景，也有开发者对autolayout不信任，总感觉没有安全感，亦或协同容易冲突，在iOS开发中能在IB中进行的操作，用代码绝对也可以，所以我们在有些时候必然要用代码来进行布局。
一般有2种方式实现约束，一种是直接添加constraint，另一种就是常说的VFL(Visual format language)，就是apple定义的一种布局约束描述的规范。

<!--more-->
为了更好的地对比理解 ，我们用三种方式来实现相同的功能用以对比。

# IB实现  

+ 添加一个view，添加约束Trailing space、Leading space、Top Space、Bottom Space。
+ 在此view上添加Top button,并添加约束Top Space、Trailing space、Leading space。
+ 在此view上，Top button下方添加Mutiple Button,并为此按钮添加约束Top Space、Align Center X。
+ 选中Top button与Mutiple Button，添加约束Equals Widths,并设置multiplier为0.5,即保持Mutiple button为top button宽度的一半。
+ 添加Bottom button, 并添加约束Trailing space、Leading space、Bottom Space。

效果如下:    
![image]({{ site.attachment }}/posts/2015-02-01-autolayout6-img1.png)

# 代码实现约束之NSLayoutConstraint  

> * 在使用代码添加约束操作前，先去掉IB中对该VC的XIB中的autolayout勾选项。
> * Disable 掉 Autoresizing

{% highlight Objective-C %}

_contentView.translatesAutoresizingMaskIntoConstraints = NO;
_topButton.translatesAutoresizingMaskIntoConstraints = NO;
_mutipleButton.translatesAutoresizingMaskIntoConstraints = NO;
_bottomButton.translatesAutoresizingMaskIntoConstraints = NO;

[self.view addConstraints:@[
                            [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:40],
                            [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-40],
                            [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:40],
                            [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-40]
                            ]];


[_contentView addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:_topButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeTop multiplier:1 constant:40],
                               [NSLayoutConstraint constraintWithItem:_topButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:40],
                               [NSLayoutConstraint constraintWithItem:_topButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-40],
                               ]];
[_contentView addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:_mutipleButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_topButton attribute:NSLayoutAttributeBottom multiplier:1 constant:40],
                               [NSLayoutConstraint constraintWithItem:_mutipleButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_topButton attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0],
                               [NSLayoutConstraint constraintWithItem:_mutipleButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                               ]];
[_contentView addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:_bottomButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-40],
                               [NSLayoutConstraint constraintWithItem:_bottomButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:40],
                               [NSLayoutConstraint constraintWithItem:_bottomButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-40],
                               ]];

{% endhighlight %}

其中NSLayoutConstraint的参数含义如下：   
{% highlight Objective-C %}
/* Create constraints explicitly.  Constraints are of the form "view1.attr1 = view2.attr2 * multiplier + constant" 
 If your equation does not have a second view and attribute, use nil and NSLayoutAttributeNotAnAttribute.
 */
+(instancetype)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(nullable id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;
{% endhighlight %}

其中的NSLayoutAttribute可选枚举：  
{% highlight Objective-C %}
typedef NS_ENUM(NSInteger, NSLayoutAttribute) {
    NSLayoutAttributeLeft = 1,
    NSLayoutAttributeRight,
    NSLayoutAttributeTop,
    NSLayoutAttributeBottom,
    NSLayoutAttributeLeading,
    NSLayoutAttributeTrailing,
    NSLayoutAttributeWidth,
    NSLayoutAttributeHeight,
    NSLayoutAttributeCenterX,
    NSLayoutAttributeCenterY,
    NSLayoutAttributeBaseline,
    NSLayoutAttributeLastBaseline = NSLayoutAttributeBaseline,
    NSLayoutAttributeFirstBaseline NS_ENUM_AVAILABLE_IOS(8_0),
    
    
    NSLayoutAttributeLeftMargin NS_ENUM_AVAILABLE_IOS(8_0),
    NSLayoutAttributeRightMargin NS_ENUM_AVAILABLE_IOS(8_0),
    NSLayoutAttributeTopMargin NS_ENUM_AVAILABLE_IOS(8_0),
    NSLayoutAttributeBottomMargin NS_ENUM_AVAILABLE_IOS(8_0),
    NSLayoutAttributeLeadingMargin NS_ENUM_AVAILABLE_IOS(8_0),
    NSLayoutAttributeTrailingMargin NS_ENUM_AVAILABLE_IOS(8_0),
    NSLayoutAttributeCenterXWithinMargins NS_ENUM_AVAILABLE_IOS(8_0),
    NSLayoutAttributeCenterYWithinMargins NS_ENUM_AVAILABLE_IOS(8_0),
    
    NSLayoutAttributeNotAnAttribute = 0
};
{% endhighlight %}


效果 :

![image]({{ site.attachment }}/posts/2015-02-01-autolayout6-img2.png)

# VFL  
如果按上面这种方式添加约束，明显太啰嗦了，apple的工程师肯定也想到了，于是就有了VFL(Visual format language)，
{% highlight Objective-C %}
/* Create an array of constraints using an ASCII art-like visual format string.
 */
+ (NSArray<__kindof NSLayoutConstraint *> *)constraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(nullable NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *, id> *)views;
{% endhighlight %}

其中的
* format 就是vfl语句:    
![image]({{ site.attachment }}/posts/2015-02-01-autolayout6-img3.png)
![image]({{ site.attachment }}/posts/2015-02-01-autolayout6-img4.png)

具体的格式请参考官方文档[Visual Format Language](https://developer.apple.com/library/watchos/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html)
* opts枚举可选值:     
{% highlight Objective-C %}
typedef NS_OPTIONS(NSUInteger, NSLayoutFormatOptions) {
    NSLayoutFormatAlignAllLeft = (1 << NSLayoutAttributeLeft),
    NSLayoutFormatAlignAllRight = (1 << NSLayoutAttributeRight),
    NSLayoutFormatAlignAllTop = (1 << NSLayoutAttributeTop),
    NSLayoutFormatAlignAllBottom = (1 << NSLayoutAttributeBottom),
    NSLayoutFormatAlignAllLeading = (1 << NSLayoutAttributeLeading),
    NSLayoutFormatAlignAllTrailing = (1 << NSLayoutAttributeTrailing),
    NSLayoutFormatAlignAllCenterX = (1 << NSLayoutAttributeCenterX),
    NSLayoutFormatAlignAllCenterY = (1 << NSLayoutAttributeCenterY),
    NSLayoutFormatAlignAllBaseline = (1 << NSLayoutAttributeBaseline),
    NSLayoutFormatAlignAllLastBaseline = NSLayoutFormatAlignAllBaseline,
    NSLayoutFormatAlignAllFirstBaseline NS_ENUM_AVAILABLE_IOS(8_0) = (1 << NSLayoutAttributeFirstBaseline),
    
    NSLayoutFormatAlignmentMask = 0xFFFF,
    
    /* choose only one of these three
     */
    NSLayoutFormatDirectionLeadingToTrailing = 0 << 16, // default
    NSLayoutFormatDirectionLeftToRight = 1 << 16,
    NSLayoutFormatDirectionRightToLeft = 2 << 16,  
    
    NSLayoutFormatDirectionMask = 0x3 << 16,  
};
{% endhighlight %}
* metrics 是fotmat中定义的动态数据的value Dictionary。  
* views则是要添加约束的view数组。

> VFL无法处理比例约束，无法处理相对居中效果

光看这个定义可能并不好理解 ，我们还是用VFL实现之前的效果:   
{% highlight Objective-C %}
NSDictionary *dic = NSDictionaryOfVariableBindings(self.view,_contentView,_topButton,_mutipleButton,_bottomButton);
[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_contentView]-40-|" options:0 metrics:nil views:dic]];
[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[_contentView]-40-|" options:0 metrics:nil views:dic]];


[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_topButton]-40-|" options:0 metrics:nil views:dic]];
[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[_topButton]" options:0 metrics:nil views:dic]];


[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_topButton]-40-[_mutipleButton]" options:0 metrics:nil views:dic]];

//我们这样设置无法居中_mutipleButton,还是得使用非VFL方式
[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_mutipleButton]-(>=0)-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:dic]];
[_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_mutipleButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

//这样添加是无效的，因为frame受到了constraint的影响，所以frame自然就无法作为我们调整比例的参考。
//    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_mutipleButton(==MutipleButtonWidth)]" options:0 metrics:@{@"MutipleButtonWidth":@(_topButton.bounds.size.width/2)} views:dic]];

//所以还是得使用NSLayoutConstraint来实现相关的比例约束
[_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_mutipleButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_topButton attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0]];


[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_bottomButton]-40-|" options:0 metrics:nil views:dic]];
[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_bottomButton(==30)]-40-|" options:0 metrics:nil views:dic]];
{% endhighlight %}

![image]({{ site.attachment }}/posts/2015-02-01-autolayout6-img5.png)

小结：一般开发中都是多种模式，多种试搭配使用，以用最简洁的代码实现功能，比如VFL并不能应对所有场景，所有会有2种代码方式搭配使用。

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/index.html#//apple_ref/doc/uid/TP40010853
