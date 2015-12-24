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

ARC一定要与Java中的自动垃圾回收机制GC区分开，二者完全不一样，ARC是编译器添加引用计数代码，而自动垃圾回收机制是运行时完全由系统来进行内存的回收，所以显然前者对内存的利用效率要高很多，以前OSX使用的自动垃圾回收机制，而iOS一开始就因为移动设备硬件本身性能问题所以就没有考虑垃圾回收机制，一直使用引用计数，iOS4.1以前开发者确实很多时候都会有疏忽的时候，而引入了ARC到现在已经非常成熟了，而且引用计数也引入到了OSX，完全替换了原来的垃圾回收机制。

那编译器如何帮开发者添加retain,release呢？这就涉及到ARC的前端编译器和优化器。  
前端编译器会根据ARC的引用计数规则找到代码中对象的创建，然后添加相对应的release，比如在方法中创建的局部对象，在方法结束前会添加release；创建的类对象也会在dealloc中添加release，实际编译过程会使用objc_retain与objc_release。  
ARC优化器即对前面做的工作的优化，删除冗余调用。  



# 属性参数与所有权描述    

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

* __autorelease:  
表示指向的对象是放入到auto release pool 中的，所以不需要处理引用计数问题，虽然和GC也有所不同，但大体上的机制一致，都是由系统进行垃圾回收。   


* __unsafe_unretained:  
我们将其拆分开，就是unretained，unsafe,unretained就跟weak类似了，是不会对引用计数增加的。unsafe表示虽然不会导致引用计数增加，但是是不安全的，因为unsafe申明过后，如果原来的持有者为nil过后，unsafe持有者并不知道，所以会crash。其实__unsafe_unretained跟assign非常像，只是assign是一个属性参数，用以告诉编译器如何生成set/get合成方法，而__unsafe_unretained是对象所有权修饰符，用于告诉编译器如何添加retain、release。

* copy:  
与retain的区别是他会拷贝一份原来的对象到一个新的地址，然后指向新的内存地址，retainCount为1。

# 循环引用  

为了说明什么是循环引用 ，我们直接举一个示例演示:   
{% highlight swift %}    
class Person {
    let name:String
    init(name:String){
        self.name = name
    }
    var company:Company?
    deinit{
        print("\(name) is being deinitialied")
    }
}
class Company {
    let name:String
    init(name:String){
        self.name = name
    }
    var ceo:Person?
    deinit{
        print("Company \(name) is being deinitialied")
    }
}
{% endhighlight %}   

新建2个类，然后Person有一个成员对象是company:Company,Company类也有一个成员对象ceo:Person。
我们在析构方法中打个日志，当对象释放时，会打印出来，表示真正的释放了，而没有保留在内存中。  
{% highlight swift %}    
var person:Person? = Person(name: "Grey")
print("person.name:\(person!.name),company.name:\(person!.company?.name)")
person = nil
{% endhighlight %}   

结果:  

> person.name:Grey,company.name:nil
> Grey is being deinitialied

我们上面没有对person的company赋值，我们给person.company赋值试一下:    
{% highlight swift %}    
var person:Person? = Person(name: "Grey")
person!.company = Company(name: "Weifocus")
print("person.name:\(person!.name),company.name:\(person!.company?.name)")
person = nil
{% endhighlight %}   

结果:   

> person.name:Grey,company.name:Optional("Weifocus")
> Grey is being deinitialied
> Company Weifocus is being deinitialied

结果依然正确，我们再把company中的ceo赋值为person试一下:  

{% highlight swift %}    
var person:Person? = Person(name: "Grey")
person!.company = Company(name: "Weifocus")
person!.company?.ceo = person
print("person.name:\(person!.name),company.name:\(person!.company?.name)")
person = nil
{% endhighlight %}   

结果：

> person.name:Grey,company.name:Optional("Weifocus")

最后一种情况就是一个最明显的循环引用,person与company均没有被释放，这一块内存变成游离状态。
如果解决呢？很简单，我们在Company的ceo加一个weak描述即可。  
{% highlight swift %}    
weak var ceo:Person?
{% endhighlight %}   

结果：

> person.name:Grey,company.name:Optional("Weifocus")  
> Grey is being deinitialied   
> Company Weifocus is being deinitialied   

> 在swift中也引入了unowned,也就是原来OC中_unretained,    
> 概念基本上是一样的，但是使用unowned修饰的变量不能是可选变量Optional，即其值不能为nil,  
> 当其引用的对象如果被释放了，它并不会自动置为nil,还是会继续指向这个无效的引用,当访问这个无效的引用时自然就会crash,  
> 当我们明确引用的对象并不会在访问时被释放，则可以使用unowned，否则有被释放的可能时就使用weak，以保证安全。    


现在我们再来看一下其它常见的几种循环引用问题:  

+ Delegate:  

比如我们在UIViewController B中申明创建一个委托协议delegate，然后在UIViewController A中创建一个对象b，并设置其delegate为a,如果B中delegate申明成了strong，则b的delegate持有a,而a中又设置了delegate为a本身，这就导致了循环引用，同样，我们可以使用weak直接解决。
{% highlight swift %}    
@objc protocol DetailModifiedProtocol{
    func modified(name:String,age:Int)
}
class Tab2ViewController: UIViewController {
    weak var delegate:DetailModifiedProtocol?
    ...
    func btnHandle(){
        if(delegate != nil){
            delegate?.modified("Grey", age: 18)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}
{% endhighlight %}   

可以看到在协议定义前，我们加了@objc指定此代码是OC，如果没有此声明则会报错:  
"weak cannot be applied to non-class type ...."

由于protocol可以适用于class、struct、enum，而对于后面2种基本数据类型，不涉及引用计数，所以无法使用weak.    
可以通过以下2种方式处理:    
1、直接指定其继承自NSObjectProtocol，说明此协议用于类，不是基本数据类型    
{% highlight swift %}    
protocol DetailModifiedProtocol:NSObjectProtocol{
    func modified(name:String,age:Int)
}
{% endhighlight %}   
2、由于OC中的protocol只能适用于类，所以可以使用swift与OC的兼容方法:    
{% highlight swift %}    
@objc protocol DetailModifiedProtocol{
    func modified(name:String,age:Int)
}
{% endhighlight %} 
 
+ Block闭包:  
闭包中如果使用了外面的对象，则会自动持有，比如最常见的self，比如self持有闭包，而闭包中又使用了self，所以就持有了self，这样就导致了循环引用。  





+ NSTimer: 


http://www.cnblogs.com/kenshincui/p/3870325.html
http://swifter.tips/retain-cycle/