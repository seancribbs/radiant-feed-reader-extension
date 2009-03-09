require File.dirname(__FILE__) + '/../spec_helper'

describe FeedCache do
  before :each do
    @cache = FeedCache.instance
  end
  
  it "should be a Simpleton" do
    FeedCache.included_modules.should include(Simpleton)
  end
  
  it "should have a cache directory that defaults to tmp/feed_cache" do
    @cache.should respond_to(:cache_dir)
    @cache.cache_dir.should == "#{RAILS_ROOT}/tmp/feed_cache"
  end
  
  it "should create the cache directory on first access if it doesn't exist" do
    old_dir = @cache.cache_dir
    @cache.cache_dir = "#{RAILS_ROOT}/tmp/testing_cache"
    FileUtils.rm_rf(@cache.cache_dir)
    @cache.get('http://seancribbs.com/atom.xml')
    File.should be_directory(@cache.cache_dir)
    @cache.cache_dir = old_dir
  end
  
  it "should save the feed to disk when fetching" do
    FileUtils.rm_f(File.join(@cache.cache_dir, '*'))
    @cache.get('http://seancribbs.com/atom.xml')
    Dir[File.join(@cache.cache_dir, '*')].should_not be_empty
  end
  
  it "should return the cached feed" do
    @old = @cache.get('http://seancribbs.com/atom.xml')
    @old.etag.should == @cache.get('http://seancribbs.com/atom.xml').etag
  end
end