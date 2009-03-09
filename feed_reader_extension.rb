class FeedReaderExtension < Radiant::Extension
  version "0.5"
  description "This extension uses Paul Dix's Feedzirra to render news feeds.  Based on scidept's original rss-reader extension."
  url "http://seancribbs.com/"

  def activate
    FeedReaderPage
    FeedCache
  end
end