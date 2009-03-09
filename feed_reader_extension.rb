class FeedReaderExtension < Radiant::Extension
  version "0.5"
  description "This extension uses Paul Dix's Feedzirra to render newsfeeds.  Inspired by scidept's original rss-reader extension."
  url "http://seancribbs.com/"

  def activate
    FeedCache
    Page.class_eval { include FeedReaderTags }
  end
end