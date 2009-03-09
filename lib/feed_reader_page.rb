require 'feedzirra'

class FeedReaderPage < Page

  tag "feed" do |tag|
    tag.locals.feed = FeedCache.get(tag.attr['url']) if tag.attr['url']
    tag.expand
  end

  tag "feed:entries" do |tag|
    tag.locals.feed = FeedCache.get(tag.attr['url']) if tag.attr['url']
    tag.locals.entries = tag.locals.feed.entries if tag.locals.feed
    tag.expand
  end

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
    tag "feed:entries:each:#{attribute}" do |tag|
      tag.locals.entry.send(attribute)
    end
  end

  tag "feed:entries:each:body" do |tag|
    tag.locals.entry.content
  end

  tag "feed:entries:each:date" do |tag|
    format = tag.attr['format'] || "%c"
    tag.locals.entry.published.strftime(format)
  end

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