---
layout: post
title: "Sequence"
description: ""
category: "Swift"
tags: []
---
{% include JB/setup %}

什么是SequenceType? 我们直接看一下其定义：
{% highlight swift %}
/// A type that can be iterated with a `for`\ ...\ `in` loop.
///
/// `SequenceType` makes no requirement on conforming types regarding
/// whether they will be destructively "consumed" by iteration.  To
/// ensure non-destructive iteration, constrain your *sequence* to
/// `CollectionType`.
protocol SequenceType : _Sequence_Type {

    /// A type that provides the *sequence*\ 's iteration interface and
    /// encapsulates its iteration state.
    typealias Generator : GeneratorType

    /// Return a *generator* over the elements of this *sequence*.
    ///
    /// Complexity: O(1)
    func generate() -> Generator
}
{% endhighlight %}
字面意思就是使类型序列化，简单的说就是为了泛型结构能够使用for...in这种方便的循环取值操作。
在Swift的类型定义中，我们可以看到String、Array等这些些基本的类型都实现了SequenceType协议。
<!--more-->
为了便于理解，我们还是来看一个实例就知道了。
{% highlight swift %}
struct Stack<T> {
    var items = [T]()
    var count:Int{
        return items.count
    }
    mutating func push(item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        return items.last!
    }
    //
    subscript(index:Int) -> T{
        get{
            precondition(index<items.count, "Index越界")
            return items[index]
        }
        set{
            precondition(index<items.count, "Index越界")
            items[index] = newValue
        }
    }
}
//---------
var stackOfStrings = Stack<String>()
for i in 1...5{
    stackOfStrings.push("stackTestValue_\(i)")
}
for item in stackOfStrings{
    println(item)
}
{% endhighlight %}
编译器抛出了错误：<span style="color: red;">'Stack<String>' does not have a member named 'Generator'</span>

这个错误就是写本文的目的，我们来添加上序列化代码：
{% highlight swift %}
extension Stack : SequenceType{
    func generate() -> GeneratorOf<T> {
        var index = 0
        return GeneratorOf{
            if index < self.items.count{
                return self.items[index++]
            }else {
                return nil
            }
        }
    }
}
{% endhighlight %}
这一下就OK了，正常输出，其实一切就这么简单～～。




参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * http://grayluo.github.io/WeiFocusIo/swift/2014/12/17/generics/
> * http://andelf.github.io/blog/2014/06/30/swift-type-hierarchy/


