---
layout: post
title: "Cocoa-Swift之循环引用"
description: ""
category: 'Cocoa-Swift'
tags: ['Cocoa-Swift']
---
{% include JB/setup %}

在iOS开发中我们经常会遇到循环引用的问题，我们本篇就专门针对循环引用一起探讨一下。

<!--more-->

# 内存管理基本概论  

我们要探讨循环引用，就先要讲一下iOS的内存管理，iOS的内存管理说白了就是引用计数，谁创建、持有，则相应对此内存块的引用计数就会增加，当不再需要持有时，则需要将引用计数减少，始终保持平衡，一旦失去这种平衡则就会出现内存泄露。即便从iOS4.1以后引入了ARC以后，引用计数的所有规则都没有变化，ARC仅仅是编译器在编译过程中帮我们添加了retain与release。

ARC一定要与Java的自动垃圾回收机制区分开，二者完全不一样，ARC是编译器添加引用计数代码，而自动垃圾回收机制是运行时完全由系统来进行内存的回收，所以显然前者的效率要高很多，以前OSX使用的自动垃圾回收机制，而iOS一开始就因为移动设备硬件本身性能问题所以就没有考虑垃圾回收机制，一直使用引用计数，iOS4.1以前开发者确实很多时候都会有疏忽的时候，而引入了ARC到现在已经非常成熟了，而且引用计数也引入到了OSX，完全替换了原来的垃圾回收机制。

那编译器如何帮开发者添加retain,release呢？这就涉及到ARC的前端编译器和优化器。  
前端编译器会根据ARC的引用计数规则找到代码中对象的创建，然后添加相对应的release，比如在方法中创建的局部对象，在方法结束前会添加release；创建的类对象也会在dealloc中添加release，实际编译过程会使用objc_retain与objc_release。  
ARC优化器即对前面做的工作的优化，删除冗余调用。



# 属性参数  

1、原子性:    

* atomic（default）:  对属性加锁，保证多线程安全。      
* nonatomic :  不对属性加锁，不保证线程安全。      

2、读写属性:   

* readwrite(default) : 会生成getter、setter方法。      
* readonly : 只生成getter方法。    

3、引用计数描述 :   

* assign :       
  一般适用于普通的非对象成员，其实就是简单的指针赋值，并不会涉及到引用计数，而且如果指向类，则最终需要赋值为nil，否则会有野指针。    
* retain :    
  强引用，类成员若有此申明，则需要在dealloc中引用计数要减少。在ARC中已经被deprecated，对应于strong    
* strong :    
  强引用。      
* weak:    
  弱引用 ，即持有并不导致引用计数增加，最终也无需assign那样需要赋值为nil。    

>  我们看到我们使用xib/storyboard创建控件时，引用的IBOutlet大都是weak的，因为view本身已经持有了这些控件，所以这些IBOutlet的生命周期与view就是一致的了。我们在IB中创建的控件 ，其实第一个持有者都是File's owner。








http://www.cnblogs.com/kenshincui/p/3870325.html