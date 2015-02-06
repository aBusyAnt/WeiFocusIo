---
layout: post
title: "AutoLayout深入浅出五[UITableView动态高度]"
description: ""
category: 'AutoLayout'
tags: ['AutoLayout']
---
{% include JB/setup %}

我们经常会遇到UITableViewCell的高度要跟随内容而调整，在未引入AutoLayout之前，我们使用以下方法计算Label高度，然后heightForRowAtIndexPath中返回计算的高度，这种做法，真的很土很局限很不好，如果UILabel使用了CoreText或者UIKit进行了富文本不同字体的排版，它更是没办法，我还得分段来计算，总之各种麻烦。
<!--more-->
{% highlight Objective-C %}
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode NS_DEPRECATED_IOS(2_0, 7_0, "Use -boundingRectWithSize:options:attributes:context:"); // NSTextAlignment is not needed to determine size
{% endhighlight %}

本系列文章我们讨论的是AutoLayout，那iOS6引入AutoLayout之后，情况是否有所变化呢？当然！而且AutoLayout在iOS不断更新过程中，也在一起不断的优化，以方便开发者进行布局。说实话，跟很多开发者一样，我目前也并不是特别喜欢AutoLayout，有一些不可控的因素，布局并没有完全掌握在自己手上，需要依赖系统根据约束进行调整，这让保守的开发人员很没有安全感。不废话了，我们还是进入到正题。

我们直接拿一个现实的需求来进行讨论，如下图，我们需要构建一个页面，上面部分显示我们预约保养的基本信息，下面部分显示该门店目前提供的优惠券列表，这种需求最简单的做法就是直接用两种UITableViewCell，下面的部分的UITableViewCell要简单一些，高度固定，而上面部分的UITableViewCell的内容有很多不确定的内容，比如用户预约保养选择的项目，门店的名称地址，这些UILabel的高度都不确定，所以导致上面部分的UITableViewCell的高度需要动态调整，这是一个比较典型的实例，我们一起来看一下如何解决。

![image]({{ site.attachment }}/posts/2015-02-01-autolayout5_1.png)

一、建立合理的约束

我们先建立自定义Cell: AppointmentedInfoCell (创建XIB)。
然后设置合理的约束条件，什么是合理的约束条件，一方面我们需要按前面讲到的设置正确的约束条件，另一方面我的意思主要是控件的compression resistance 和 hugging constraints ，在IB中如下图：

![image]({{ site.attachment }}/posts/2015-02-01-autolayout5_2.png)

我们知道在Autolayout中，我们的UILabel,UIButton等控件都有了内建大小（intrinsic content size），就是说控件的大小会根据内容进行自动调整，可以将这些控件的大小和ScrollView的bounds和contentSize进行对比，意思有点类似，只不过UILabel,UIButton这些控件并不像Scrollview一样可以在bounds不等于contentSize的情况下进行滚动查看内容。
在这里为了使用UILabel的内建大小，我们要保持compression resistance 和 hugging constraints 的垂直方向优先级没有被更高的优先级所覆盖，比如更改了UILabel内建大小的优先级(priority),并设置了UILabel的高度约束的优先级高于内建大小的优先级，那内建大小自然就不起作用了，就会以高优先级为准.

> * 下面是官方关于intrinsic content size的说明：
	Custom views typically have content that they display of which the layout system is unaware. Overriding this method allows a custom view to communicate to the layout system what size it would like to be based on its content. This intrinsic size must be independent of the content frame, because there’s no way to dynamically communicate a changed width to the layout system based on a changed height, for example.
[Editing Auto Layout Constraints](https://developer.apple.com/library/ios/recipes/xcode_help-IB_auto_layout/chapters/EditingConstraintAttributesintheAttributesInspector.html)

一方面我们确保了AppointmentedInfoCell中的控件，目前全是UILabel，其内建大小垂直方向优先级为最高的1000。
光这个还不够，我们还要确保内建大小的边缘跟随内建大小一起变化，从而保证我们的内建大小可以起作用，说白了，就是要求contentView中的子控件建立与superView的约束，我们先建立第一个UILabel（姓名、电话）与superview top 的间距约束，然后依次往下建立控件之间推荐间距的约束，左边同列控件建立左部对齐约束，右边同行内容的建立顶部对齐约束，垂直方向的间距约束，最底部的"预约结果Label"建立与superview bottom的间距约束。

特别提醒：与contentView的四边间距约束很重要，有了4个与contentView的边缘约束，才能保证contentView的大小跟随其subviews变化。

上面这些就是建立合理的约束条件，这里随便提醒一下，UILabel在IB中布局的大小如果跟内容计算出来的不一致就会有警告，比如UILabel长度为200，目前的内容为2个14号字的长度，那UILabel就会有警告，对于这种警告，你需要忍住你的强迫症。

二、计算行高

这一步在iOS7与iOS8上面就有所不同了，我们先来看最新的iOS8。

1、iOS8:

从iOS8开始引入了UITableViewCell的高度的自适应功能，在iOS8之前实现很麻烦的功能，iOS8以后就不需要自己动手去做了，稍后我们会看一下iOS7下面如何做。
{% highlight Objective-C %}
//打开tableview的高度估算功能
_iTableView.rowHeight = UITableViewAutomaticDimension;
_iTableView.estimatedRowHeight = 70.0;
{% endhighlight %}

estimatedRowHeight必须设置为大于0，为了画面的过度顺畅，保证UITableview的高度变化不至于导致UITableview的大范围滚动而影响了用户视觉体验，我们用一个预估的平均值，这也就是所谓的预估值。estimatedRowHeight并不是最终的行高，当一个Cell需要显示的时候，会精确计算实际的行高，contentView的宽度就是UITableview的宽度减去Section Index，accessoryView等的宽度，contentView的高度则会自动根据其子视图的约束关系计算，当此精确值被计算出过后，estimatedRowHeight、tableview的contentSize,bounds,这些都会跟随更新。

estimatedRowHeight每一行都会使用此值用于该行的预估值，进而初步预估UITableView的contentSize。如果UITableView每行内容变化很大，行高差别很大，那我们可以使用以下方法为每一行设置各不相同的预估值。也就是说有通用值，也有个性值。

{% highlight Objective-C %}
- (void)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
{% endhighlight %}

OK,预估值只是一个插曲，我们来看精确值，在iOS8过后，我们只需简单的激活预估值，并在heightForRowAtIndexPath中返回UITableViewAutomaticDimension即可。

{% highlight Objective-C %}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IOS8_OR_ABOVE) {
            return UITableViewAutomaticDimension;
    }
}
{% endhighlight %}

2、iOS7:

UITableViewCell的contentView的高度自适应是iOS8中加入的，iOS7就只能自己计算了，所以我们来看一下iOS7下如何处理的。

{% highlight Objective-C %}

//NIB注册，获取自定义UITableView实例的方式有很多种，这里随便用一种
UINib *cellNib = [UINib nibWithNibName:@"AppointmentedInfoCell" bundle:nil];
[self.tableView registerNib:cellNib forCellReuseIdentifier:@"AppointmentedInfoCell"];



//先创建一个基本的Cell实例,我们后面cellForRowAtIndexPath 和  heightForRowAtIndexPath 都需要用，由于UITableView的加载过程是先计算出所有的行高，再对每行进行渲染的，即 heightForRowAtIndexPath是先调用的，所以这里的baseCell就是一个离屏控件，用于辅助计算高度的，而后面也可以直接使用其用于每行内容的更新，每种类型的Cell只需要一个即可，这样我们的离屏内存并不会浪费。

_baseCell = [cellNib instantiateWithOwner:nil options:nil][0]; 


//更新Cell内容
- (void)configureCell:(AppointmentedInfoCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	//更新contentView的子控件
}

//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppointmentedInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentedInfoCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:_baseCell atIndexPath:indexPath];
    [_baseCell layoutSubviews];
    CGFloat height = [_baseCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height + 1;//由于分割线，所以contentView的高度要小于row 一个像素。
}
{% endhighlight %}

写本文时，为了能够提供一个全面的解决方案不至于太局限，以免误导读者，我翻阅了很多文章，基本思想都是以上这样，区别在于细节的处理上，比如UItableViewCell的实例化就有很多种方式比如：
{% highlight Objective-C %}
static NSString *CellIdentifier = @"AppointmentedInfoCell";
AppointmentedInfoCell *cell = (AppointmentedInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
if (cell == nil)
{
    NSArray *cellTeam = [[NSBundle mainBundle] loadNibNamed:CellIdentifier
                                                      owner:self
                                                    options:nil];
    cell = [cellTeam objectAtIndex:0];
}
{% endhighlight %}

也有的网友巧妙的使用了dispatch_once：

{% highlight Objective-C %}
static AppointmentedInfoCell *baseCell;
static dispatch_once_t onceToken;

dispatch_once(&onceToken, ^{
	baseCell = [[AppointmentedInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyTableViewCellIdentifier];
});
{% endhighlight %}

OK,到这里，我们基本上就掌握了AutoLayout的UITableViewCell的动态高度的处理，关键点就是systemLayoutSizeFittingSize的使用，希望本篇能够帮助你更好的理解AutoLayout以及UITableView在iOS8新增的布局处理。

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * http://blog.jldagon.me/blog/2013/12/07/auto-layout-and-uitableview-cells/
> * [对应demo](https://github.com/jilouc/TableViewAutoLayout)
> * http://useyourloaf.com/blog/2014/02/14/table-view-cells-with-varying-row-heights.html
> * [对应demo](https://github.com/kharrison/CodeExamples/tree/master/Huckleberry)
> * http://www.raizlabs.com/dev/2014/02/leveraging-auto-layout-for-dynamic-cell-heights/
> * [对应demo](https://github.com/Raizlabs/RZCellSizeManager/tree/master/RZCellSizeManagerDemo)
> * http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights
> * [中文翻译版](http://codingobjc.com/blog/2014/10/15/shi-yong-autolayoutshi-xian-uitableviewde-celldong-tai-bu-ju-he-ke-bian-xing-gao/)
> * [PureLayout](https://github.com/smileyborg/PureLayout)
> * http://www.raywenderlich.com/73602/dynamic-table-view-cell-height-auto-layout
> * https://github.com/Alex311/TableCellWithAutoLayout
> * http://www.ifun.cc/blog/2014/02/21/dong-tai-ji-suan-uitableviewcellgao-du-xiang-jie/
> * http://blog.amyworrall.com/post/66085151655/using-auto-layout-to-calculate-table-cell-height
> * http://www.macspotsblog.com/dynamic-uitableview-cell-heights-programmatically/
> * http://www.cnblogs.com/gatsbywang/p/4216706.html