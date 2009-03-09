require 'feedzirra'

class FeedReaderPage < Page

  desc %{
    The root of the feed namespace.  Can take the 'url' attribute
    to scope all contained tags to a specific newsfeed.
  }
  tag "feed" do |tag|
    tag.locals.feed = FeedCache.get(tag.attr['url']) if tag.attr['url']
    tag.expand
  end

  desc %{
    Selects the entries of a given feed.  Can take the 'url' attribute
    to scope all contained tags to a specific feed - otherwise it will
    inherit the feed from the parent context.
  }
  tag "feed:entries" do |tag|
    tag.locals.feed = FeedCache.get(tag.attr['url']) if tag.attr['url']
    tag.locals.entries = tag.locals.feed.entries if tag.locals.feed
    tag.expand
  end


  desc %{
    Iterates over all the entries in the feed, rendering the contained
    block in the context of the entry.  The @url@ attribute is required
    if a parent tag does not define it. Optional @limit@, @by@, and @order@ 
    attributes.
    
    *Usage:*
    
    <pre><code><r:feed:entries:each url="http://somefeed.com/rss" [limit="10"] [order="desc"] [by="published"]>
      output something for the entry
    </r:feed:entries:each></code></pre>
  }
  tag "feed:entries:each" do |tag|
    raise StandardTags::TagError, "`url' attribute is required" unless tag.attr['url'] || tag.locals.feed
    tag.locals.feed = FeedCache.get(tag.attr['url']) if tag.attr['url']
    entries = (tag.locals.entries ||= tag.locals.feed.entries)
    entries_with_options(entries, tag).map do |entry|
      tag.locals.entry = entry
      tag.expand
    end.join
  end

  [:title, :url, :author, :summary].each do |attribute|
    desc %{
      Outputs an entry's #{attribute}.
      
      *Usage:*
      
      <pre><code><r:feed:entries:each url="http://somefeed.com/rss">
        <r:#{attribute} />
      </r:feed:entries:each></code></pre>
    }
    tag "feed:entries:each:#{attribute}" do |tag|
      tag.locals.entry.send(attribute)
    end
  end


  desc %{
    Outputs an entry's body.
    
    *Usage:*
    
    <pre><code><r:feed:entries:each url="http://somefeed.com/rss">
      <r:body />
    </r:feed:entries:each></code></pre>
  }
  tag "feed:entries:each:body" do |tag|
    tag.locals.entry.content
  end

  desc %{
    Outputs an entry's published datetime.  The format may be specified with the
    @format@ attribute using Ruby's @strftime@ syntax.
    
    *Usage:*
    
    <pre><code><r:feed:entries:each url="http://somefeed.com/rss">
      <r:date [format="%c"] />
    </r:feed:entries:each></code></pre>
  }
  tag "feed:entries:each:date" do |tag|
    format = tag.attr['format'] || "%c"
    tag.locals.entry.published.strftime(format)
  end

  desc %{
    Creates an HTML link to the original source of the entry, adding
    any additional attributes to the @<a>@ tag.  If no content is given,
    the entry title will be used.
    
    *Usage:*
    
    <pre><code><r:feed:entries:each url="http://somefeed.com/rss">
      <r:link />
    </r:feed:entries:each></code></pre>
    
    <pre><code><r:feed:entries:each url="http://somefeed.com/rss">
      <r:link class="foo"/>
    </r:feed:entries:each></code></pre>
    
    <pre><code><r:feed:entries:each url="http://somefeed.com/rss">
      <r:link>Read more...</r:link>
    </r:feed:entries:each></code></pre>
  }
  tag "feed:entries:each:link" do |tag|
    attributes = tag.attr.reject{|k,v| k.to_s == 'href' }.map do |key, value|
      %Q[#{key}="#{value}"]
    end.join(" ")
    contents = tag.double? ? tag.expand : tag.locals.entry.title
    %Q[<a href="#{tag.locals.entry.url}"#{" " + attributes unless attributes.blank?}>#{contents}</a>]
  end

  def entries_with_options(entries, tag)
    if tag.attr['by']
      entries = entries.sort_by(&(tag.attr['by'].to_sym))
    end
    if tag.attr['order'] == 'desc'
      entries = entries.reverse
    end
    if tag.attr['limit']
      entries = entries[0, tag.attr['limit'].to_i]
    end
    entries
  end
end