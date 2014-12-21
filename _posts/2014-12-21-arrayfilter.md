---
layout: post
title: "数组常用操作技巧"
description: ""
category: "Swift"
tags: []
---
{% include JB/setup %}

本文重点在于探讨数组的常用操作，对其中的过滤器与归约的关注多一些，我们先来看一下Array的一些常用操作，这些操作都有一些通用的特性，理解了其中一个，其它也就类推即可。
<!--more-->
先看一下常用操作,闭包的使用请参考：[闭包](http://numbbbbb.gitbooks.io/-the-swift-programming-language-/content/chapter2/07_Closures.html)：
1.排序,Sort:
{% highlight swift %}
var array = [1,2,3,4,5]
array.sort{$0 < $1}
println(array)
array.sort{$0 > $1}
println(array)
{% endhighlight %}
> 输出结果：    
> [1, 2, 3, 4, 5]  
> [5, 4, 3, 2, 1]

2.逆序,Reverse
{% highlight swift %}
var array = [1,2,3,4,5]
println(array.reverse())
{% endhighlight %}
> 输出结果：  
> [1, 2, 3, 4, 5]

3.映射,Map
{% highlight swift %}
var array = [1,2,3,4,5]
let x = array.map{$00 * 2}
println(x)
{% endhighlight %}
> 输出结果：  
> [2, 4, 6, 8, 10]

4.归约,Reduce
{% highlight swift %}
var array = [1,2,3,4,5]
let x = array.reduce(10){$0 + $1}
println(x)
{% endhighlight %}

5.过滤器,Filter
{% highlight swift %}
var array = [1,2,3,4,5]
let x = array.filter{$0 % 2 == 0}
println(x)
{% endhighlight %}

6.Slice,这个特性很有意思,算一个惊喜吧，留在下一篇来讨论：[Slice]({{ production_url }}/2014/12/21/slice/).

通过以上的例子我们可以看到Array提供的这些常用方法使用的模式都差不多，我们来重点讨论两个。
先看过滤器：
{% highlight swift %}
var array = [1,2,3,4,5]

//method 1
func customFilter(num:Int) -> Bool{
    return num % 2 == 0
}
let x = array.filter(customFilter)
println(x)

//method 2
let y = array.filter{
    $0 % 2 == 0
}
println(y)

//method 3
func myGenericsFilter<T>(src:[T],predicate:(T) ->Bool) ->[T]{
    var rs = [T]()
    for i in src{
        if predicate(i){
            rs.append(i)
        }
    }
    return rs
}
let z = myGenericsFilter(array){$0 % 2 == 0}
println(z)
{% endhighlight %}
以上几种方式根据自己的爱好选择均可。

我们再来看一下Reduce，这个归约是Array强大功能的又一体现，可以处理数组的复杂运算。
{% highlight swift %}
var array = [1,2,3,4,5]
var events = array.filter({
    (num) in
    num % 2 == 0
})
println(events)
let eventSum = events.reduce(0){
    (total,num) in
    total + num
}
println(eventSum)
{% endhighlight %}
其中reduce的使用定义为：
{% highlight swift %}
func reduce<U>(initial: U, combine: (U, T) -> U) -> U
{% endhighlight %}
第一个参数为初始值，类型为U，上例中初始值为0，类型为Int，第二个参数为一个函数，这个函数返回的值即是Reduce的值。

用简写连接起来使用：
{% highlight swift %}
var eventSum = array.filter{$0 % 2 == 0}.reduce(0){$0 + $1}
println(eventSum)
{% endhighlight %}

换种类型：
{% highlight swift %}
var array = [1,2,3,4,5]
let numberPrinter = array.reduce("numbers:"){
    (initValue,number) in
    initValue + "\(number) ,"
}
println(numberPrinter)
{% endhighlight %}
这个例子中reduce的初始值为String,返回的也是String。   
最后我们再来画蛇添足一下，换一种方式,我们不使用Array提供的标准函数，而自定义一个Reduce，跟上面的myGenericsFilter类似，我们按上面的例子要实现的目的来自己定义一个Reduce函数，仅仅是为了更好的理解，但是实际上一般情况下我们使用Array提供的函数完全足够：
{% highlight swift %}
extension Array{
    func myReduce<T,U>(seed:U,combiner:(U,T)->U) ->U{
        var currentValue = seed
        for item in self{
            currentValue = combiner(currentValue,item as T)
        }
        return currentValue
    }
}
let myReduceRs = array.myReduce(2){
    (seed,current) in
        seed + current
}
{% endhighlight %}

经过上面这么多例子的练习，应该对Array的常用函数明了吧～_～

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * http://www.raywenderlich.com/store/swift-by-tutorials
> * http://grayluo.github.io/WeiFocusIo/swift/2014/12/17/generics/
> * http://onevcat.com/2014/06/walk-in-swift/

