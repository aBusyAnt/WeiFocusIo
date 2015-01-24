---
layout: post
title: "AutoLayout深入浅出二[基本使用]"
description: ""
category: 'AutoLayout'
tags: [AutoLayout]
---
{% include JB/setup %}
在上一篇中我们一起讨论了Autolayout出生之前的iOS布局方式，并讲了以前的布局方式的缺陷，从而引入了AutoLayout,这篇文章我们就直接上正餐了。
接到上一篇的示例，我们使用Autolayout来完成autoresizingMask无法完成的使命，我们先在File inspector中激活autolayout，我们在Size Inspector中再也看不到autoresizingMask了，取而代之，我们可以在视图下方看到4个操作按钮。
<!--more-->


<img src="{{ site.attachment }}/posts/2015-01-24-autolayout2_1.PNG" width="949" height="703"/>

依次选中3个视图，然后在菜单Editor -> Pin 中以此为3个视图添加约束（Constraints）或者直接选中视图点击底部第二个按钮（指向它，稍后会提示Pin）在里面直接激活某个constraints,并点击Add constraints，在autolayout中我们将布局的名称改为约束，就是建立视图之间 以及 视图与父视图之间的约束关系，由这些约束关系确定各个view的位置与大小。

1、 红色View添加约束Constraints：
	Leading Space to Superview ，Trailing Space to View，Top Space to Superview ，Bottom Space to View 。
2、橙色View添加约束Constraints:	
	Leading Space to View ，Trailing Space to Superview，Top Space to Superview ，Bottom Space to View 。
3、蓝色View添加约束Constraints:
	Leading Space to Superview ，Trailing Space to Superview，Top Space to View ，Bottom Space to Superview.

即
红色View添加约束为 保持前置距离 ，保持后置与橙色View的距离，保持顶部距离，保持底部与蓝色View的距离。
橙色View添加约束为 保持前置与红色View的距离 ，保持后置距离，保持顶部距离，保持底部与蓝色View视图的距离。
蓝色View添加约束为 保持前置距离 ，保持后置距离，保持顶部与红色View的距离，保持底部距离。

添加完这些预约我们会发现好多橙色线条，分别选中3个View时都会出现一个橙色的虚线框，这都是IB在提示我们，约束不够或者矛盾而无法确定view的大小，也有可能约束的值和当前布局的值并不一致而导致警告，比如红色view距离上边距现在是31，但是我在Top Space to Superview 中设置的是20，IB会非常聪明的发现这些，并给出警告。如果发现左侧的view旁边有了红色箭头，这表示view的位置无法确定，必须修改，否则view布局结果完全未知，严重时可能会导致crash。如果是黄色表示constrints的值和当前IB中的值不一致，可能是笔误。但是最好让每个view的旁边什么都没有。橙色虚线框表示根据constraints计算的结果可能该view会呈现的位置与大小。  

<img src="{{ site.attachment }}/posts/2015-01-24-autolayout2_2.PNG" width="957" height="688"/>  

IB已经提示我们添加的这些约束还不够，我们看一下详细的约束错误提示：
	红色view缺少水平方向的位置或者宽度，缺少垂直方向的位置或者高度,还有一个警告表示根据约束条件计算表示view应该为268x515，但是现在是132x159。
	橙色view缺少水平方向的位置或者宽度，缺少垂直方向的位置或者高度,还有一个警告表示根据约束条件计算表示view应该为268x515，但是现在是303x515。
	蓝色view缺少垂直方向的位置或者高度,还有一个警告表示根据约束条件计算表示view应该为560x0，但是现在是204x356。

这太奇怪了？怎么了，不是自动布局很牛B吗？怎么这么多问题？抓狂！！！！
抓狂完了，我们还是得回来继续看，到底是怎么回事？
其实我们静下来看着view思考一小下，就清楚了。

我们的约束能够确定红色View的顶部位置与左部位置，但是无法确定右部位置与底部位置，因为这是同一层级的视图间的约束，有依赖关系，
比如红色view的后置距离相对于橙色距离保持，但是这有一个前提就是橙色的位置要确定才行呀？不然彼此依赖，还是无法解决间距padding问题。
如果你是系统你拿到的约束关系是两个视图的左右边距和间距，你就能够确定位置了吗？当然不能，这样子的约束，系统是无法确定左边的视图占的宽一点还是右边的视图占的宽一点。
所以还得添加一个约束来确定两个视图的各自的宽，这里我们添加一个相等的约束，这样系统就会用其supeview的width减去左边距、右边距，中间padding，然后再除以2就可以确定两个视图的宽度了，如下图示：  

<img src="{{ site.attachment }}/posts/2015-01-24-autolayout2_3.PNG" width="797" height="641"/>  

如果你不想要相等，比如你要红色view是橙色view的1/2怎么办？很简单，你可以先设置为相等，然后再设置这个constraint的Multiplier，你可以把相等（Equal）看成是Multiplier为1的情况，Multiplier就是两个view间的倍数关系，就是First Item是Second Item的多少倍，是一个Float，比如这里设置为1.5就是红色view的宽度是橙色view的1.5倍，如果为0.5表示红色view是橙色view的0.5倍。
OK，我们红色View与橙色View的水平方向的约束确定了，原来这两个view水平方向的橙色线条变成了蓝色，原来水平方向的位置或宽度警告也没有了。

我们添加一个预览看一下效果，预览是xcode6以后添加的非常有用的一个工具，可以直观的看到各个尺寸下的视图表现。操作如下：  

<div style="width:1500px;overflow-x:scroll">
  <div style="width:1500px">
  <img src="{{ site.attachment }}/posts/2015-01-24-autolayout2_4.PNG" width="1009" height="682"/>
  <img src="{{ site.attachment }}/posts/2015-01-24-autolayout2_5.PNG" width="569" height="707" />
  <img src="{{ site.attachment }}/posts/2015-01-24-autolayout3_6.PNG" width="807" height="681" />
  </div>
</div>

垂直方向，我们同样采用这种方式，我们这里红色和橙色高度一样，与蓝色间距也一样，所以我们随便为红色与蓝色，橙色与蓝色添加一个相等约束，添加过后再修改Multiplier即可，这样垂直方向的红色警告就没有了，只剩下黄色警告了，是一些constraint位置与当前布局的不一致，我们可以点击依次点击黄色标签，根据IB提示，让IB帮我们按constraints来调整当前布局，
OK，这样，所有的警告都没有了，只剩下蓝色的线条。  

<img src="{{ site.attachment }}/posts/2015-01-24-autolayout2_7.PNG" width="1085" height="681"/>

我们打开这个xib文件看一下AutoLayout到底如何写的：  

<img src="{{ site.attachment }}/posts/2015-01-24-autolayout2_8.PNG" width="1085" height="681"/>  

现在的xib文件真是比以前的简洁多了，以前的xib文件太过复杂，大家都在抱怨多人协作时只要打开过xib文件，就会导致xib文件被改动，git提交时必然会要求提交该改动，这样子冲突就经常容易发生。好歹Apple的工程师们简化了xib的格式。  
我们看到xib文件中有两块，一块是autoresizingMask，一块是constraints，可能有人就会说了，IB中只要激活了AutoLayout，则autoresizingMask就没有了吗？怎么这里面还会有？上面的autoresizingMask块其实就是描述我们在xib中布局时展显的内容，是我们开发过程中给开发人员调整参考使用的，如果这种在固定大小的view上面拖拽也使用constraints来进行计算未免也太浪费了，更何况根本没有必要，实际上app运行过程中的布局与此无关，而完全由下面的constraints块确定。
我们看到xib文件中constraint都是这样写的，IB会为每个view生成一个3段串码，为每个预约条件也会生成一个唯一的id,并描述该约束的相关view及其约束类型与约束值。    

> <constraint firstItem="Oja-YK-2U3" firstAttribute="top" secondItem="HAY-ER-wAq" secondAttribute="bottom" constant="14" id="pb1-Ge-D4E"/>

****技巧:    
一、使用IB提供的建议约束：  
对于不是很复杂的页面，我们可以使用layout下面的第三个按钮中的Reset to suggested constraints,IB会自动添加视图间的约束，然后我们再确认是否有必要进行修正。
比如我们用上面的例子来试一下，就得到IB自动创建constraints的结果：  

<img src="{{ site.attachment }}/posts/2015-01-24-autolayout2_8.PNG" width="679" height="682"/>  

IB还算蛮聪明的，它并没有为红色view与橙色view添加固定的高度，但是遗憾的是它还是给蓝色的view添加了距离父视图固定的距离，这与我们的想法并不一致，不过IB已经经历了，在众中选项中，它确实无法明确我们到底要哪一种，它就只能按自己的想法给提供给我们一种了，这让我想到了《疑犯追踪》S04-11，这一集真是太精彩了，机器在为Finch们寻找逃生方案时不断的模拟，而最终为其提供一个生存率相对相高的方案。我们再在些基础上稍加修改即可，使用建议约束一定要检查IB给的建议约束是否是我们想要的。

二、在设置约束时，可以直接将一个view右键拖动到目标view 为二者建立约束关系。

三、在预约出现错误或者警告时，可以点击红色与黄色标签使用IB的推荐解决方案。

四、底部的4个操作按钮在菜单Editor中都可以找到，依次用于对齐、约束、IB建议。

五、在拖拽视图时，尽量使用每个view都至少有两个蓝色的参考线，视图之间按[HIG(Human Interface Guidelines)](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/index.html)的标准保持8px以上间距。


参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！   
> * http://www.raywenderlich.com/50317/beginning-auto-layout-tutorial-in-ios-7-part-1
> * https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/index.html


