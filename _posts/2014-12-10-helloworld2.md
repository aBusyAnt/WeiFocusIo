---
layout: post
title: "HelloWorld2"
description: ""
category: 
tags: []
---
{% include JB/setup %}

以看出，文章的 front-matter 部分设置了多项值，以后可以通过类似 post.title, post.category 的方式引用这些些，另外，layout部分的值和之前解释的一样， 文件的内容会被填充到 _layouts/default.html 文件的 content 变量中。

另外，文章中 为什么不试试呢之后的有三个不可见的 \n，它决定了这三个 \n 之前的内容会被放在 post.excerpt 变量中，供其它文件使用。

_includes
这个文件中，存放着一些模块文件，例如 categories.ext，其它文件可以通过

{% raw %}
{% include categories.ext %}
{% endraw %}
来引用这个文件的内容，方便代码模块化和重用。我的博客 主页上的 分类，归档，这些模块的代码都是通过这种方式引用的。

_plugins
这个文件中存放一些Ruby插件, 例如 gen_categories.rb，这些文件会在 Jekyll 解析网站源代码时被执行。下一节讲述的就是插件。

_site
Jekyll 解析整个网站源代码后，会将最终的静态网站源代码放在这里


