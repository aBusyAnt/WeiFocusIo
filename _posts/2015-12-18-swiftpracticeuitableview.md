---
layout: post
title: "Cocoa-Swift之UITableView相关一(基本使用)"
description: ""
category: 'Cocoa-Swift'
tags: ['Cocoa-Swift']
---
{% include JB/setup %}
UITableView是iOS开发中最常见的布局展示容器，是各种复杂布局都会使用的一种容器。  
基本流程:   
1、声明实现UITableViewDelegate、UITableViewDataSource。   
2、使用IB或者代码创建UITableView,并设置其delegate与dataSource为self。   
3、实现dataSource方法，实现delegate方法。    

<!--more-->

1、创建TableView:  
{% highlight swift %}  
let tableView = UITableView(frame: CGRect(x: 0, y:0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), style: UITableViewStyle.Plain)
tableView.delegate = self
tableView.dataSource = self
self.view.addSubview(tableView)
{% endhighlight %} 
我们看到TableView显示在Status Bar下面，我们需要将其下移 状态栏Bootm高度：   



{% highlight swift %}  
- (void) viewDidLayoutSubviews {
    CGRect viewBounds = self.view.bounds;
    CGFloat topBarOffset = self.topLayoutGuide.length;
    viewBounds.origin.y = topBarOffset * -1;
    self.view.bounds = viewBounds;
}
{% endhighlight %} 


2、DataSource示例:  
{% highlight swift %}  
// MARK: - UITableViewDataSource
func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
}
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    return 20
}

func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return 60.0
        }else{
            return 40.0
        }
    }else{
        return 50.0
    }
}
func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return getHeaderHeightForSection(section)
}
func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return getFooterHeightForSection(section)
}
func getHeaderHeightForSection(section:Int) ->CGFloat{
    if(section == 0){
        return 30.0
    }else{
        return 40.0
    }
}

func getFooterHeightForSection(section:Int) ->CGFloat{
    return 30.0
}


func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UIView(frame: CGRect(x: 0,y: 0,width: tableView.bounds.size.width,height: getHeaderHeightForSection(section)))
    header.backgroundColor = UIColor.blueColor();
    
    let label = UILabel(frame: CGRect(x: 5, y: 5, width: 100, height: 20))
    label.text = "Header title"
    label.font = UIFont.systemFontOfSize(14)
    label.textColor = UIColor.redColor()
    header.addSubview(label)
    
    
    let btn = UIButton(type: UIButtonType.Custom)
    btn.frame = CGRect(x: label.frame.origin.x+label.frame.size.width, y: label.frame.origin.y, width: 100, height: 20)
    btn.setTitle("头部按钮", forState: UIControlState.Normal);
    header.addSubview(btn)
    
    
    return header
}
func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: getFooterHeightForSection(section)))
    footer.backgroundColor = UIColor.whiteColor()
    
    let btnWidth:CGFloat = 100.0
    let btn = UIButton(frame: CGRect(x: (tableView.bounds.size.width - btnWidth)/2, y: 5, width: btnWidth, height: 20.0))
    btn.setTitle("底部按钮", forState: UIControlState.Normal)
    footer.addSubview(btn)
    
    return footer
}
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let identifierString = "identifierString"
    var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifierString)
    if(cell == nil){
        cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifierString)
    }
    cell?.textLabel?.textColor = UIColor.blackColor()
    cell?.textLabel?.text = "cell - " + String(stringInterpolationSegment: indexPath.row)
    return cell!
}
{% endhighlight %} 
3、UITableViewDelegate 示例:
{% highlight swift %}  
// MARK: - UITableViewDelegate
func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    print("selected index:" , indexPath.row)
}
func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if(editingStyle == UITableViewCellEditingStyle.Delete){
        print("del index:",indexPath.row)
    }else if(editingStyle == UITableViewCellEditingStyle.Insert){
        print("insert index:",indexPath.row)
    }
}
{% endhighlight %} 



