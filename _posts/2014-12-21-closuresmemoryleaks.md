---
layout: post
title: "闭包中的内存泄漏陷阱"
description: ""
category: "Swift" 
tags: []
---
{% include JB/setup %}

闭包就跟Block在OB中带给我们的强大一样，闭包是我们的强大的武器，具体的概念与使用请参考文档：[闭包(Closures)](http://numbbbbb.gitbooks.io/-the-swift-programming-language-/content/chapter2/07_Closures.html)
我们这里只来讨论一下在闭包使用过程中可能会遇到的一个隐秘的大问题：Memory leaks !
首先我们来回顾一下我们在Object-C中使用Block的时候有没有遇到相同的问题？
<!--more-->
我们用最常用的例子来说明，在一个子VC中进行操作以触发父VC中得到相应的响应操作：
{% highlight Objective-C %}
//先定义子VC，子VC中调用testValueChangeHandle方法时将会触发父VC的响应操作，即其定义的Block将会调用。
//  BlockTestVC.h
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ResultCode){
    OK,
    Error,
};
@interface BlockTestVC : UIViewController
@property ResultCode resultCode;
@property (nonatomic,copy) void (^executeFinishedBlock)(void);
@end

//BlockTestVC.m
@implementation BlockTestVC
- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"BlockTest Constructor!");
    }
    return self;
}
- (void)dealloc{
    NSLog(@"BlockTest Destroyed !");
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)testValueChangeHandle{
    if(arc4random()%2 == 0){
        _resultCode = OK;
    }else{
        _resultCode = Error;
    }
    _executeFinishedBlock();
}
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
{% endhighlight %}
在父VC中我们定义BlockTestVc,并传入block响应操作：
{% highlight Objective-C %}
- (void)blockTest{
    BlockTestVC *testVc = [[BlockTestVC alloc]init];
    testVc.executeFinishedBlock  = ^{
        NSLog(@"test without block");
    };
    [self presentViewController:testVc animated:YES completion:nil];
}
{% endhighlight %}

输出正常：

> BlockTest Constructor!  
> BlockTest Destroyed !

现在我们将block中的代码变化一下：
{% highlight Objective-C %}

- (void)blockTest{
    BlockTestVC *testVc = [[BlockTestVC alloc]init];
    testVc.executeFinishedBlock  = ^{
        if(testVc.resultCode == OK){
            NSLog(@"result is ok.");
        }else{
            NSLog(@"result is error.");
        }
    };
    [self presentViewController:testVc animated:YES completion:nil];
}

@end
{% endhighlight %}

看起来没问题？编译器已经发现了问题：

> <span style="color: orange;"> Capturing 'testVc' strongly in this block is likely to lead to a retain cycle </span>  

意思就是说Block中对testVc拥有强引用，这样一来，testVc 永远不会销毁，在程序执行过程中，我们发现 "BlockTest Destroyed !" 这条语句是永远不会输出的，导致内存泄漏是肯定的。
对于这样的问题，我们以前如何处理的呢?很简单：
{% highlight Objective-C %}

- (void)blockTest{
    BlockTestVC *testVc = [[BlockTestVC alloc]init];
    __weak typeof(testVc)weakTestVc = testVc;
    testVc.executeFinishedBlock  = ^{
        if(weakTestVc.resultCode == OK){
            NSLog(@"result is ok.");
        }else{
            NSLog(@"result is error.");
        }
    };
    [self presentViewController:testVc animated:YES completion:nil];
}
{% endhighlight %}
这样代码就可以正常输出了。

回顾了一下OC中的这个问题，在Swift是不是也会有呢？不幸的是，答案是肯定的，我们来看个例子：
偷个懒,以下示例来源于[《Swift by Tutorials》](http://www.raywenderlich.com/store/swift-by-tutorials)
{% highlight swift %}
//  Person.swift
//
class Person {
  let name: String
  private let actionClosure: (() -> ())!
  
  init(name: String) {
    
    self.name = name
    
    actionClosure = {
      println("I am \(self.name)")
    }
  }
  
  func performAction() {
    actionClosure()
  }
  
  deinit {
    println("\(name) is being deinitialized")
  }
}


//  ViewController.swift
//
class ViewController: UIViewController {                            
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let person = Person(name: "bob")
    person.performAction()
}

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
{% endhighlight %}
程序执行结果只会输出：I am bob  
什么原因？看下图的对象引用关系：  

<img src="{{ site.attachment }}/posts/Snip20141221_1.png" align="center" width="400" height="150">  

很明显的相互引用导致的引用循环，从而viewDidLoad执行完成过后，局部变量Person应该被销毁，ViewConroller没有了person的引用，但还有一个闭包却在引用，结果对象引用关系就变成了这样的：  

<img src="{{ site.attachment }}/posts/Snip20141221_2.png" align="center" width="400" height="150">  

问题与Object-C中是一样的，当然解决办法也一样,将闭包更新一下：
{% highlight swift %}

    actionClosure = {
      [unowned self]() -> () in
      println("I am \(self.name)")
    }
{% endhighlight %}
> 输出：  
> I am bob  
> bob is being deinitialized

OK,输出正常，但愿你一切都明了～

   
  
  

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * http://www.raywenderlich.com/store/swift-by-tutorials
> * http://numbbbbb.gitbooks.io/-the-swift-programming-language-/content/chapter2/07_Closures.html




