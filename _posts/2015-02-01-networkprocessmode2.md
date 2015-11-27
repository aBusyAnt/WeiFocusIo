---
layout: post
title: "iOS网络处理封装模式二[代理模式]"
description: ""
category: 'Network Process'
tags: ['Network Process']
---
{% include JB/setup %}

上一篇可我们一起了解了iOS系统中的http网络请求方法，通过了解apple提供的api，我们可以清楚网络交互的流程，以及apple引导我们的网络交互习惯，从NSURLConnection到NSURLSession，我们不能光会用第三方写好的API，我们还要跟随一个平台的发展方向，以便我们不落伍。本篇以及下一篇，我们就讲一下如何在实际生产过程中封闭第三方库以方便我们的网络交互处理，本篇先从简单的代理模式讲起走。





