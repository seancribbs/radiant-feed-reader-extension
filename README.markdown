feed_reader Extension
=====================

About
-----
This is a Radiant CMS extension (inspired by the `rss_reader_extension`) that adds some tags to fetch and display syndication feeds. It uses Paul Dix's [Feedzirra library][1] and is able to cache the parsed feed data to disk to take advantage of Feedzirra's awesome bandwidth-saving features.

Installation
------------
Follow the installation instructions for [Feedzirra][1].

Then run this:

<pre><code>$ script/extension install feed_reader </code></pre>

That's it! There are no migrations or public files.  If you absolutely must install it manually:

<pre><code>$ git clone git://github.com/seancribbs/radiant-feed-reader-extension.git vendor/extensions/feed_reader </code></pre>

or

<pre><code>$ git submodule add git://github.com/seancribbs/radiant-feed-reader-extension.git vendor/extensions/feed_reader</code></pre>

This extension is tested on Radiant 0.7.1.

Usage
-----

Use it in your page like this (just an example):

<pre><code>&lt;r:feed:entries:each url=&quot;http://www.somefeed.com/rss&quot; limit=&quot;5&quot;&gt;
  &lt;div class=&quot;feed-entry&quot;&gt;
    &lt;h2&gt;&lt;r:link /&gt;&lt;/h2&gt;
    &lt;div class=&quot;meta&quot;&gt;by &lt;r:author /&gt; on &lt;r:date format=&quot;%Y-%m-%d&quot;/&gt;&lt;/div&gt;
    &lt;div class=&quot;summary&quot;&gt;&lt;r:summary /&gt;&lt;/div&gt;
  &lt;/div&gt;
&lt;/r:feed:entries:each&gt;</code></pre>

[1]: http://github.com/pauldix/feedzirra