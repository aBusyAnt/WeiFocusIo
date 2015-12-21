---
layout: post
title: "Cocoa-Swift之Extension"
description: ""
category: 'Cocoa-Swift'
tags: ['Cocoa-Swift']
---
{% include JB/setup %}
在OC中我们使用Category提高的代码的规范，减少了冗余，在swift中虽然不再有Category了，但是有了类似功能的Extension，相比于Category而言，Extension没有名称，而且不能定义存储属性（当然我们可以使用runtime解决，稍后会讲到）。

<!--more-->

Extensions可以扩展的内容包括:   
+ 添加计算型属性和计算静态属性  
+ 定义实例方法和类型方法  
+ 提供新的构造器  
+ 定义下标  
+ 定义和使用新的嵌套类型  
+ 使一个已有类型符合某个接口  


# 基本语法  
+ 属性与方法:
{% highlight swift %}    
extension SomeType {
    // 加到SomeType的新功能写到这里
}
{% endhighlight %}   
+ 协议:
{% highlight swift %}    
extension SomeType: SomeProtocol, AnotherProctocol {
    // 协议实现写到这里
}
{% endhighlight %}   

# 计算属性Computed Properties      
{% highlight swift %}  
//CustomCell   
extension CustomCell{
    var defaulHeight:Float{
        return 50;
    }
}
//test
let cell = CustomCell(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
let defaultHeight = cell.defaulHeight
print("default height:\(defaultHeight)")
{% endhighlight %}   

# 存储属性  

虽然我们前面已经讲到了，默认的extension不支持存储属性，我们来试一下：  
{% highlight swift %}  
//CustomCell   
extension CustomCell{
    var company:String?
}
{% endhighlight %}   

> 编译器直接就提示: Extensions may not contain stored properties

但是有时候我们也会有这种需要在Extension中添加存储属性的时候，比如我们使用别人的第三方库时，那我们有没有其它办法可以实现在Extension中添加存储属性呢，当默认的方法都实现不了的时候，在iOS开发中不论是OC还是Swift，我们都可以考虑一下Runtime。
{% highlight swift %} 
//CustomCell 
extension CustomCell{
    private struct AssociatedKeys{
        static var name = "CustomCell_name"
        static var location = "CustomCell_location"
    }
    var name:String?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.name) as? String
        }
        set{
            if let newValue = newValue{
                objc_setAssociatedObject(self, &AssociatedKeys.name, newValue as String, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    var location:String?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.location) as? String
        }
        set{
            if let newValue = newValue{
                objc_setAssociatedObject(self, &AssociatedKeys.location, newValue as String, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

//test
let cell = CustomCell(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
cell.name = "Grey.Luo"
cell.location = "成都市高新区"
print("cell.name:\(cell.name),cell.location:\(cell.location)")
{% endhighlight %}   

以上就是一个最基本的使用Runtime给Extension添加存储属性的示例，其中objc_getAssociatedObject与objc_setAssociatedObject中都会用到一个关联key，可以把其想作是KVC的那种思想，为了不对整个类和命名空间(即模块)导致污染，使用这种私有嵌套结构体的方式是业内大牛们推荐的方式，OK，我们再看一下runtime的文档:  
{% highlight swift %} 
 /** 
 * Sets an associated value for a given object using a given key and association policy.
 * 
 * @param object The source object for the association.
 * @param key The key for the association.
 * @param value The value to associate with the key key for object. Pass nil to clear an existing association.
 * @param policy The policy for the association. For possible values, see “Associative Object Behaviors.”
 * 
 * @see objc_setAssociatedObject
 * @see objc_removeAssociatedObjects
 */
@available(iOS 3.1, *)
public func objc_setAssociatedObject(object: AnyObject!, _ key: UnsafePointer<Void>, _ value: AnyObject!, _ policy: objc_AssociationPolicy)

/** 
 * Returns the value associated with a given object for a given key.
 * 
 * @param object The source object for the association.
 * @param key The key for the association.
 * 
 * @return The value associated with the key \e key for \e object.
 * 
 * @see objc_setAssociatedObject
 */
@available(iOS 3.1, *)
public func objc_getAssociatedObject(object: AnyObject!, _ key: UnsafePointer<Void>) -> AnyObject!
{% endhighlight %}   

# 构造器Initializers   
{% highlight swift %} 
//CustomCell
extension CustomCell{
    convenience init(defaultHeight:Float){
        self.init()
        print("convenience init...\(defaultHeight)")
    }

//test
let cell = CustomCell(defaultHeight: 50)
{% endhighlight %}   

# 普通方法Methods 
{% highlight swift %}  
extension CustomCell{    
    func normalFun(param1:String,param2:Int){
        print("normalFun,\(param1),\(param2)")
    }
}
{% endhighlight %}   

> PS: 一旦某个扩展方法中要修改实例本身，则需要在方法前添加mutating，而且仅支持结构体与枚举的扩展,不支持类和协议，其实就是数据类型与类在系统中的存储机制不一样。
如:  
{% highlight swift %}  
extension Int{
    mutating func doubleIt(){
        self = self * 2
    }
}
{% endhighlight %}   
以下方法则不行: 
{% highlight swift %}  
class CustomOb: NSObject {
    var customName:String?
    var customLocation:String?
    init(name:String, location:String) {
        customName = name
        customLocation = location
     }
}
extension CustomOb{
    mutating func modifyMyself(defaultHeight:Float){
        self = CustomOb(name: "Grey.Luo", location: "成都高新")
    }
} 
{% endhighlight %}    
以上这样对CustomOb进行扩展，无法使用mutating进行实例修改，直接报错:  

> 'mutating' isn't valid on methods in classes or class-bound protocols

# 下标(Subscripts)  
如果对Subscripts不太熟悉的同学，可以查看[Cocoa-Swift之Subscripts]()

{% highlight swift %}  
//CustomOb
class CustomOb: NSObject {
    var customName:String?
    var customLocation:String?
    init(name:String, location:String) {
        customName = name
        customLocation = location
     }
}
extension CustomOb{
    subscript(index:Int) -> String{
        var rs:String? = nil
        if(index == 0){
            rs = customName
        }else if(index == 1){
            rs = customLocation
        }
        return rs!
    }
}
//test
let customOb = CustomOb(name: "Grey.Luo", location:"成都高新")
print("\(customOb[0]),\(customOb[1])")
{% endhighlight %}    

# 嵌套类型(Nested Types)  
我们前面在讲存储属性的时候其实已经涉及到了，前面嵌套了一个结构体用于Runtime的关联key。我们再来一个枚举示例。     
{% highlight swift %}  
class CustomOb: NSObject {
    var customName:String?
    var customLocation:String?
    var customGroup:String?
    
    init(name:String , location:String , group:String?) {
        customName = name
        customLocation = location
        customGroup = group
    }
    
    enum Sex{
        case Secret,Man,Woman
    }
    var sex:Sex{
        switch(customGroup?.lowercaseString){
            case "ManGroup"?:
                return .Man
            case "WomanGroup"?:
                return .Woman
            default:
                return .Secret
        }
    }
}

//test
let customOb = CustomOb(name: "Grey.Luo", location:"成都高新" ,group: nil)
print("customOb.Sex:\(customOb.sex)")
{% endhighlight %}    

参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * [Swift & the Objective-C Runtime](http://nshipster.cn/swift-objc-runtime/)
> * [Swift文档-扩展](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Extensions.html#//apple_ref/doc/uid/TP40014097-CH24-ID151)
