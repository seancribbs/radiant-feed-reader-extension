require 'digest/sha1'
require 'feedzirra'

class FeedCache
  include Simpleton
  
  attr_accessor :cache_dir
  
  def get(url)
    FileUtils.mkdir_p(cache_dir) unless File.directory?(cache_dir)
    if cache_exists?(url)
      feed = load_from_cache(url)
      feed = Feedzirra::Feed.update(feed)
      save_to_cache(url, feed)
      feed
    else
      feed = Feedzirra::Feed.fetch_and_parse(url)
      save_to_cache(url, feed) unless feed.is_a?(Fixnum)
      feed
    end
  end
  
  private
    def cache_file(url)
      File.join(cache_dir, cache_key(url))
    end
    
    def cache_exists?(url)
      File.exist?(cache_file(url))
    end
    
    def cache_key(url)
      Digest::SHA1.hexdigest(url)
    end
    
    def load_from_cache(url)
      Marshal.load(File.read(cache_file(url)))
    end
    
    def save_to_cache(url, object)
      File.open(cache_file(url), "w") {|f| f.write Marshal.dump(object) }
    end
    
    def initialize
      @cache_dir = "#{RAILS_ROOT}/tmp/feed_cache"
    end
end