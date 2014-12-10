---
layout: page
title: 首页
---
{% include JB/setup %}

<ul class="posts">
  {% for post in site.posts %}
  	<a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a> <br>
    {{ post.date | date_to_string }} <br>
    {{ post.category }} <br>
    {{ post.excerpt }}
  {% endfor %}
</ul>
