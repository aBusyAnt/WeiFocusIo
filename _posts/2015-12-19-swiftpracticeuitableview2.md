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
}
extension CustomCell{
    func updateCustomCellWithOb(ob:CustomOb){
        descriptionLabel.text = ob.blogDescription
        locationLabel.text = ob.authorLocation
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

使用IB创建的Cell的其它方式:    
{% highlight swift %}   
let nib = UINib(nibName: "CustomCell", bundle: NSBundle.mainBundle())
let obs:Array = nib.instantiateWithOwner(self, options: nil) as Array
cell = obs[0] as? CustomCell
{% endhighlight %}   

# 使用代码创建无xib的Cell:   
若复用cell使用如下方式则必须需要先注册cell:   
{% highlight swift %}   
public func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UITableViewCell 
// newer dequeue method guarantees a cell is returned and resized properly, assuming identifier is registered
{% endhighlight %}   
1、创建一个自定义Cell:  
{% highlight swift %}   
class CustomCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:style , reuseIdentifier:reuseIdentifier)
        initGui()
    }
    init(defaultHeight:Float,reuseIdentifier:String){
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        initGui()
    }
    var nameLabel:UILabel = UILabel(frame: CGRectZero)
    var locationLabel:UILabel = UILabel(frame: CGRectZero)
    func initGui(){
        nameLabel.frame = CGRect(x: 5, y: 5, width: 100, height: 20)
        nameLabel.font = UIFont.systemFontOfSize(14)
        nameLabel.textColor = UIColor.blackColor()
        self.contentView.addSubview(nameLabel)
        
        locationLabel.frame = CGRect(x: 5, y: 30, width: 100, height: 20)
        locationLabel.font = UIFont.systemFontOfSize(12)
        locationLabel.textColor = UIColor.lightGrayColor()
        self.contentView.addSubview(locationLabel)
    }
}
{% endhighlight %}   



2、注册cell:   
{% highlight swift %}   
let cellIdentifier:String = "reuseIdentifier"
self.tableView.registerClass(CustomCell.self, forCellReuseIdentifier: cellIdentifier) 
{% endhighlight %}   

3、cellForRowAtIndexPath:  
{% highlight swift %}   
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let  cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! CustomCell
    cell.nameLabel.text = "Cell name -\(indexPath.row)"
    cell.locationLabel.text = "Cell location-\(indexPath.row)"
    return cell
}
{% endhighlight %}   

直接使用dequeueReusableCellWithIdentifier，则不需要提前注册cell:  

{% highlight swift %}   
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let reuseIdentifier:String = "reuseIdentifier"
    var cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? CustomCell
    if(cell == nil){
        cell = CustomCell(defaultHeight: 60.0, reuseIdentifier: reuseIdentifier)
    }
    cell!.nameLabel.text = "Cell name -\(indexPath.row)"
    cell!.locationLabel.text = "Cell location-\(indexPath.row)"
    return cell!
}
{% endhighlight %}   







