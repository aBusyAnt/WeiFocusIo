---
layout: post
title: "数组索引(分组)"
description: ""
category: "Swift"
tags: []
---
{% include JB/setup %}
在实际的应用中，数组索引使用的太广泛了，通讯录中的姓名、航班的城市名、汽车品牌名等等这些都需要根据拼音第一个字母(-_-！拼音的字母)或者英文的首字母建立索引，也就是分组，分组后的列表可以大大提高用户的查看效率。
<!--more-->
建立拼音库是第一步，直接使用这个就可以了:[Pinyin](https://github.com/GrayLuo/pinyin-For-Objective-C)
由于我们使用Swift，而Pinyin里面是C的函数，这里就偷懒不更改[Pinyin](https://github.com/GrayLuo/pinyin-For-Objective-C)了,直接添加一个Object-C中间类ChineseString用于转换。
{% highlight Objective-C %}
//  ChineseString.h
@interface ChineseString : NSObject
@property(nonatomic,strong) NSString *string;
@property(nonatomic,strong) NSString *firstPinyinLetter;
- (id)initWithString:(NSString *)str;
@end


//  ChineseString.m
#import "ChineseString.h"
#import "pinyin.h"
@implementation ChineseString
- (id)initWithString:(NSString *)str{
    self = [super init];
    if (self) {
        self.string = str;
        if (self.string.length > 0) {
            self.firstPinyinLetter = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([self.string characterAtIndex:0])]uppercaseString];;
        }
    }
    return  self;
}
@end
{% endhighlight %}
按正常的逻辑来实现建立索引并分组：
{% highlight swift %}
typealias Entry = (Character,[String])

    func buildIndex(words:[String]) -> [Entry]{
        var result = [Entry]()
        var letters = [Character]()
        //1.建立索引表
        for word in words{
            let chineseStr = ChineseString(string: word)
            let firstLetter = Character(chineseStr.firstPinyinLetter)
            if !contains(letters,firstLetter){
                letters.append(firstLetter)
            }
        }
        //2.按索引分组
        for letter in letters{
            var wordsForLetter = [String]()
            for word in words{
                let chineseStr = ChineseString(string: word)
                let firstLetter = Character(chineseStr.firstPinyinLetter)
                if firstLetter == letter{
                    wordsForLetter.append(word)
                }
            }
            result.append((letter,wordsForLetter))
        }
        return result
    }
    func arrayIndexsTest(){
        var names = ["张三","张四","张三疯","杨树","李五","王麻子","乔布斯","比尔盖茨","库克","马云","扎克","拉里","李彦宏","柳传志","马化腾","未来的你"]
        println(buildIndex(names))
    }
{% endhighlight %}
> 输出：  
> [(Z, [张三, 张四, 张三疯, 扎克]), (Y, [杨树]), (L, [李五, 拉里, 李彦宏, 柳传志]), (W, [王麻子, 未来的你]), (Q, [乔布斯]), (B, [比尔盖茨]), (K, [库克]), (M, [马云, 马化腾])]  

好像一切还挺不错，但是有没有看到这个代码有点丑 ？不太优雅，根据之前的泛型与数组的常用操作，我们可以改进一下代码：
{% highlight swift %}
    typealias Entry = (Character,[String])
    func distinct<T:Equatable>(source:[T]) -> [T]{
        var unique = [T]()
        for item in source{
            if !contains(unique,item){
                unique.append(item)
            }
        }
        return unique
    }
    
    func buildIndex(words:[String]) -> [Entry]{
        //1.建立索引表
        let letters = words.map{
            (word) -> Character in
            let chineseStr = ChineseString(string: word)
            return Character(chineseStr.firstPinyinLetter)
        }
        let distinctLetters = distinct(letters)
        //2.按索引分组
        return distinctLetters.map{
            (letter) -> Entry in
            return (letter,words.filter{
                let chineseStr = ChineseString(string: $0)
                return Character(chineseStr.firstPinyinLetter) == letter
            })
        }
    }
    func arrayIndexsTest(){
        var names = ["张三","张四","张三疯","杨树","李五","王麻子","乔布斯","比尔盖茨","库克","马云","扎克","拉里","李彦宏","柳传志","马化腾","未来的你"]
        println(buildIndex(names))
    }
{% endhighlight %}
> 输出：  
> [(Z, [张三, 张四, 张三疯, 扎克]), (Y, [杨树]), (L, [李五, 拉里, 李彦宏, 柳传志]), (W, [王麻子, 未来的你]), (Q, [乔布斯]), (B, [比尔盖茨]), (K, [库克]), (M, [马云, 马化腾])]  

我们来看一下，distinct方法中,我们用到了泛型函数，用到了Array的Map操作，Filter操作。
本文介绍的内容实际应用中非常常见，希望你明了了~_~


参考：  
本文主要用于一个知识的归纳总结，过程中可能会引用到其它地方的文字或代码，如有侵权请及时联系我，在此对写作过程中参考了的文章作者表示感谢！ 

> * http://www.raywenderlich.com/store/swift-by-tutorials
> * http://numbbbbb.gitbooks.io/-the-swift-programming-language-/content/chapter2/07_Closures.html
> * http://grayluo.github.io/WeiFocusIo/swift/2014/12/21/arrayfilter/

