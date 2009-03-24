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
    FileUtils.rm_rf(@cache.cache_dir)
    @cache.get('http://seancribbs.com/atom.xml')
    Dir[File.join(@cache.cache_dir, '*')].should_not be_empty
  end
  
  it "should not save the feed to disk if there is an error in fetching" do
    FileUtils.rm_rf(@cache.cache_dir)
    @cache.get('http://seancribbs.com/this-does-not-exist')
    Dir[File.join(@cache.cache_dir, '*')].should be_empty
  end
  
  it "should not save the updated feed to disk if there is an error in fetching" do
    FileUtils.rm_rf(@cache.cache_dir)
    @oldfeed = @cache.get('http://seancribbs.com/atom.xml')
    Feedzirra::Feed.stub!(:update).and_return(0)
    @cache.get('http://seancribbs.com/atom.xml')
    @cache.send(:load_from_cache, 'http://seancribbs.com/atom.xml').etag.should == @oldfeed.etag
  end
  
  it "should return the cached feed" do
    @old = @cache.get('http://seancribbs.com/atom.xml')
    @old.etag.should == @cache.get('http://seancribbs.com/atom.xml').etag
  end
  
  it "should clean duplicates from the feed after updating" do
    old_feed = @cache.get('http://seancribbs.com/atom.xml')
    extra_entry = old_feed.entries.first.dup
    old_feed.entries.push extra_entry
    @cache.should_receive(:load_from_cache).with('http://seancribbs.com/atom.xml').and_return(old_feed)
    new_feed = @cache.get('http://seancribbs.com/atom.xml')
    new_feed.entries.should_not include(extra_entry)
  end
end