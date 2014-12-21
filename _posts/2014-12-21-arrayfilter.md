---
layout: post
title: "数组过滤器"
description: ""
category: "Swift"
tags: []
---
{% include JB/setup %}

虽然本文重点在于探讨数组过滤器，但是在介绍过滤器之前，我们先来看一下Array的一些常用操作，这些操作都有一些通用的特性，理解了其中一个，其它也就类推即可。
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

3.Map
{% highlight swift %}
var array = [1,2,3,4,5]
let x = array.map{$00 * 2}
println(x)
{% endhighlight %}
> 输出结果：  
> [2, 4, 6, 8, 10]

4.Reduce
{% highlight swift %}
var array = [1,2,3,4,5]
let x = array.reduce(10){$0 + $1}
println(x)
{% endhighlight %}


