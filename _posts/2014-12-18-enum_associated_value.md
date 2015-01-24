---
layout: post
title: "枚举相关值"
description: ""
category: "Swift" 
tags: ['swift']
---
{% include JB/setup %}

枚举的定义与基本的使用，我这里就不罗嗦了，可以参考[官方文档](http://numbbbbb.gitbooks.io/-the-swift-programming-language-/content/chapter2/08_Enumerations.html)
我这里只讲一下Swift的不同与重点需要注意的地方，Swift中的枚举成员可以自定义类型，可以是Character、Int、String等，但是光这种简单的基本数据类型就足够了吗？我们肯定欲求不满，我们希望可以定义为任何我们想要的自定义类型，而且在一个枚举中可以定义为各不相同的类型，就是枚举相关值的概念(Associated Values)。

<!--more-->
先来看一个基本类型的定义
{% highlight swift %}
enum EnumTest: String {
    case sss = "sss"
    case ddd = "ddd"
    case xxx = "xxx"
}
let enumVar = EnumTest.sss
println(enumVar.rawValue)
//result is sss
{% endhighlight %}

我们来看一个多类型的示例：
{% highlight swift %}
enum Barcode {
  case UPCA(Int, Int, Int)
  case QRCode(String)
}
var productBarcode = Barcode.UPCA(8, 85909_51226, 3)
//
productBarcode = .QRCode("ABCDEFGHIJKLMNOP")
//
switch productBarcode {
case .UPCA(let numberSystem, let identifier, let check):
    println("UPC-A with value of \(numberSystem), \(identifier), \(check).")
case .QRCode(let productCode):
    println("QR code with value of \(productCode).")
}
// 输出 "QR code with value of ABCDEFGHIJKLMNOP.”
{% endhighlight %}
从中我们可以看出，枚举的定义并不包括任何的实际值，而仅仅是定义了当productBarcode的值等于UPCA时，相关的值的类型。
小技巧 ：

> 如果一个枚举成员的所有相关值被提取为常量，或者它们全部被提取为变量，为了简洁，你可以只放置一个var或者let标注在成员名称前：
	{% highlight swift %}
switch productBarcode {
case let .UPCA(numberSystem, identifier, check):
    println("UPC-A with value of \(numberSystem), \(identifier), \(check).")
case let .QRCode(productCode):
    println("QR code with value of \(productCode).")
}
// 输出 "QR code with value of ABCDEFGHIJKLMNOP."
{% endhighlight %}

看完了基本类型的各种使用，我们来看一个自定义类作为枚举成员的示例，其定义方式跟上面的基本类型是一致的，就不啰嗦了，自己看下代码：
{% highlight swift %}
class Car{
    var engine:String
    var gearbox:String
    init(engine:String,gearbox:String){
        self.engine = engine
        self.gearbox = gearbox
    }
}
class Horse{
    var eyesCount:Int
    var legsCount:Int
    init(eyesCount:Int,legsCount:Int){
        self.eyesCount = eyesCount
        self.legsCount = legsCount
    }
}
enum Vehicle{
    case Cars(Car)
    case Horses(Horse)
    case Others(String)
}
let myCar = Car(engine:"BMW 130i",gearbox:"AT")
let vehicle = Vehicle.Cars(myCar)
switch (vehicle) {
    case .Cars(let car):
        println("vehicle is car:\(car.engine),\(car.gearbox)")
    case .Horses(let horse):
        println("vehicle is horse")
    default:
        println("vehicle is others")
}
{% endhighlight %}

还有一个比较好的枚举应用场景，就是对数据查询的时候，我们会有两种情况，一个是Found，就直接返回相应结果，另一个就是NotFound,在这里，我们使用闭包进行回调处理，比如进行UITableView的刷新等操作。
{% highlight swift %}
class Horse{
    var eyesCount:Int
    var legsCount:Int
    init(eyesCount:Int,legsCount:Int){
        self.eyesCount = eyesCount
        self.legsCount = legsCount
    }
}
class People{
    enum SearchResult{
        case Results([Horse])
        case Error
    }
    typealias SearchCompletion = (result:SearchResult) -> Void
    class func search(keyword:String,completion:SearchCompletion){
        let result = arc4random_uniform(10)
        switch(result){
            case 1...5:
                let foundTheHorse = Horse(eyesCount: 2, legsCount: 4)
                completion(result: .Results([foundTheHorse,]))
            default:
                completion(result: .Error)
        }
    }
}
People.search("theKeyWord"){
    switch($0){
        case .Results(let results):
        	//对查询结果进行处理
            println("Found,the \(results.count) results")
        case .Error:
            println("Get Error,NotFound")
        
    }
}
{% endhighlight %}
这样一写，是不是代码很现代？使用“现代”的语言，当然要写出“现代”的风格~~





本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * http://www.raywenderlich.com/82572/swift-generics-tutorial
> * http://numbbbbb.gitbooks.io/-the-swift-programming-language-/content/chapter2/08_Enumerations.html
