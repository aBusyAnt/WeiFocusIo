---
layout: post
title: "Cocoa-Swift之UITableView相关二(自定义Cell)"
description: ""
category: 'Cocoa-Swift'
tags: ['Cocoa-Swift']
---
{% include JB/setup %}

UITableView使用率非常高，而其使用中最重要的一点就是自定Cell，我们用最常见的2种方式来试一下: 

<!--more-->

# 一、使用IB自定义Cell   
1、在IB中新建UITableViewCell，选中新建xib，命名为CustomCell 并在其上添加各种控件，eg:  
![image]({{ site.attachment }}/posts/2015-12-19-swiftpracticeuitableview2-img1.png)
2、在IB中添加IBOutlet,并设置其类为CustomCell。

{% highlight swift %}   
class CustomCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    ......
	extension CustomCell{
	    func updateCustomCellWithOb(ob:CustomOb){
	        descriptionLabel.text = ob.blogDescription
	        locationLabel.text = ob.authorLocation
	    }
	}
}
{% endhighlight %}   

3、新建CustomCell对应的CustomOb，或者category，即创建Model。

{% highlight swift %}   
class CustomOb: NSObject {
    var blogDescription:String? = nil
    var authorLocation:String? = nil
    
    override init() {
        blogDescription = nil
        authorLocation = nil
    }
    init(description:String,location:String) {
        blogDescription = description
        authorLocation = location
    }
}
{% endhighlight %}   


4、在VC中创建Cell,并设置Cell。  
{% highlight swift %}   
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {        
    let identifierString:String = "CustomCell"
    var cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier(identifierString) as? CustomCell
    if(cell == nil){
        let nib = NSBundle.mainBundle().loadNibNamed("CustomCell", owner: self, options: nil)
        cell = nib.last as? CustomCell
    }
    let ob = CustomOb(description: "国辉"+"\(indexPath.row)", location: "成都市高新区" + "\(indexPath.row)")
    cell?.updateCustomCellWithOb(ob)
    return cell!
}
{% endhighlight %}   







