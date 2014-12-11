---
layout: page
---
{% include JB/setup %}

<ul class="posts">
  {% for post in site.posts %}
  	<h2><a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></h2> <br>
	{{ post.date | date: "%Y" }}年{{ post.date | date: "%m" }}月{{ post.date | date: "%d" }}日
	<a class="post-category" href="/page/category.html#{{ post.categories }}">{{ post.categories }}</a>
	<div class="post-main">
      {{ post.content | split:'<!-- more -->'| first }}
      <div class="readall"><a href="{{ BASE_PATH }}{{ post.url }}" id="post-readall">阅读全文&nbsp;<i class="fa fa-chevron-right"></i></a></div>
    </div>
{% endfor %}
	{% if paginator.has_next %}
	<nav class="pager">
		<a href="/archive" class="next">Continue</a>
	</nav>
	{% endif %}
</ul>
