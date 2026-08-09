---
layout: page
title: DEV LOG
icon: fas fa-code
order: 1
permalink: /devlog/
---

<div class="devlog-page">
{% assign devlog_posts = site.tags['SAP'] | sort: 'date' | reverse %}
{% assign current_year = "" %}
{% for post in devlog_posts %}
  {% assign post_year = post.date | date: "%Y" %}
  {% if post_year != current_year %}
    {% unless forloop.first %}</div>{% endunless %}
    <h2 class="devlog-year">{{ post_year }}</h2>
    <div class="list-group mb-4">
    {% assign current_year = post_year %}
  {% endif %}
  <a href="{{ post.url | relative_url }}" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center px-0 py-2 border-0 border-bottom">
    <span>{{ post.title }}</span>
    <span class="text-muted small ms-3 text-nowrap">
      {% if post.categories.size > 0 %}<span class="badge rounded-pill text-bg-secondary me-2">{{ post.categories.first }}</span>{% endif %}
      {{ post.date | date: "%m-%d" }}
    </span>
  </a>
{% endfor %}
{% unless devlog_posts.size == 0 %}</div>{% endunless %}

{% if devlog_posts.size == 0 %}
<p class="text-muted">아직 DEV LOG에 올라온 글이 없습니다.</p>
{% endif %}
</div>
