---
layout: post
title: "sizeclasses"
description: ""
category: 
tags: []
---
{% include JB/setup %}

iOS6引入的AutoLayout，但是屏幕尺寸不断多样化，AutoLayout在面对多尺寸屏幕时仍然有心无力，所以apple在iOS8引入了一个全新的概念，size classes。
size  classes推翻了屏幕尺寸的概念，而是引入Regular、Compact概念，把实际各个设备屏幕尺寸及其旋转导致的变化转化为以下9种size类别。就是apple把所有屏幕及其旋转导致的变化都用这9种类别囊括，开发者只需要关心这几种虚拟尺寸类别即可而无需再关心真正的设备尺寸。

<!--more-->

![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img1.png)
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img2.png)

![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img3.png)
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img4.png)

![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img5.png)
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img6.png)

![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img7.png)
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img8.png)

![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img9.png)

难道我们每一个View都要做9个布局吗？当然不是，所有布局其实都是继承自己wAny和hAny,在此类别下布局基本的公用布局，然后在各个需要特别布局的类别下做只在其状态下的布局。相当于wAny与hAny是基类，而其它8种类别是继承自基类，在各个子类中进行相应的布局处理。  
我们在选择类别时，XCode提示我们此布局对应于相应的设备屏幕尺寸：  
我们9种模式下分别修改布局内容，然后查看预览即可看到只会在对应的屏幕尺寸下有效。  

##  Compact Width | Compact Height : 3.5寸、4寸、4.7寸 三种尺寸横屏时有效。  
+ 切换到Compact Width|Compact Height类别下，添加Label,添加约束：距superview top高度、宽度、水平居中。    
+ 添加4种尺寸的预览，3.5-inch、4-inch、4.7-inch、5.5-inch。  
+ 查看4种尺寸的预览:    
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img10.png)    
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img11.png)  


## wAny | hCompact : 对所有尺寸的横屏有效。   
+ 切换到wAny | hCompact模式：添加Label2，添加约束：label2 top与Label1 bottom固定距离、固定宽度、水平居中。  
+ 预览4种尺寸效果:  
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img12.png)    
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img13.png)    

## wRegular | hCompact : 仅针对5.5寸横屏。   
+ 切换到Regular | hCompact 模式，添加Label3,添加约束:label3 top与Label2 bottom固定距离、固定宽度、水平居中。  
+ 预览4种尺寸效果:  
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img14.png)     
![image]({{ site.attachment }}/posts/2015-12-09-sizeclass-img15.png)    
## wCompact | hAny :   
## wAny | hAny :   
## wRegular | hAny :   
## wCompact | hRegular : 
## wAny | hRegular : 
## wRegular | hRegular : 

