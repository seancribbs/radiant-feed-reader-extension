require File.dirname(__FILE__) + '/../spec_helper'

describe FeedReaderPage do
  dataset :home_page

  before :each do
    @feed = Feedzirra::Feed.parse(File.read(File.dirname(__FILE__) + "/../fixtures/seancribbs.xml"))
    FeedCache.stub!(:get).and_return(@feed)
    @page = FeedReaderPage.create(:title => "Feeds", :slug => "feeds", :breadcrumb => "Feeds", :parent_id => page_id(:home))
  end

  describe "<r:feed>" do
    it "should emit its contents" do
      @page.should render('<r:feed>foo</r:feed>').as("foo")
    end
    
    it "should load the feed if the url is given" do
      FeedCache.should_receive(:get).with('http://seancribbs.com/atom.xml').and_return(@feed)
      @page.should render('<r:feed url="http://seancribbs.com/atom.xml">foo</r:feed>').as('foo')
    end
  end
  
  describe "<r:feed:entries>" do
    it "should emit its contents" do
      @page.should render('<r:feed:entries>foo</r:feed:entries>').as("foo")
    end
    
    it "should load the feed if the url is given" do
      FeedCache.should_receive(:get).with('http://seancribbs.com/atom.xml').and_return(@feed)
      @page.should render('<r:feed:entries url="http://seancribbs.com/atom.xml">foo</r:feed:entries>').as('foo')
    end
    
    it "should load the entries from the feed" do
      @feed.should_receive(:entries).and_return([])
      @page.should render('<r:feed:entries url="http://seancribbs.com/atom.xml">foo</r:feed:entries>').as('foo')
    end
    
    it "should load the entries from the feed of a higher context" do
      @feed.should_receive(:entries).and_return([])
      @page.should render('<r:feed url="http://seancribbs.com/atom.xml"><r:entries>foo</r:entries></r:feed>').as('foo')
    end
  end

  describe "<r:feed:entries:each>" do
    it "should raise an error if no url attribute is given and no feed is present from the context" do
      @page.should render('<r:feed:entries:each />').with_error("`url' attribute is required")
    end
    
    it "should load the feed" do
      FeedCache.should_receive(:get).with('http://seancribbs.com/atom.xml').and_return(@feed)
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" />').as('')
    end
    
    it "should load the entries from the feed" do
      @feed.should_receive(:entries).and_return([])
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" />').as('')
    end
    
    it "should iterate over each entry" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml">1</r:feed:entries:each>').as('1111111111')
    end
    
    it "should limit the number in the iteration" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="5">1</r:feed:entries:each>').as('11111')
    end
    
    it "should reorder the entry list" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" by="published"><r:title /> </r:feed:entries:each>').as(%q[Resurrecting feed_tools Resurrecting feed_tools, part 2 Raleigh RubyCamp Logo Code Highlighting for Erlang Riemann Dances at Raves Getting into Erlang, Playing Telephone Content Management That Won't Rot Your Brain RedCloth 4 vs. CodeHighlighter Iteration in herml Nominate your Ruby Hero! ])
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" by="title"><r:title /> </r:feed:entries:each>').as("Code Highlighting for Erlang Content Management That Won't Rot Your Brain Getting into Erlang, Playing Telephone Iteration in herml Nominate your Ruby Hero! Raleigh RubyCamp Logo RedCloth 4 vs. CodeHighlighter Resurrecting feed_tools Resurrecting feed_tools, part 2 Riemann Dances at Raves ")
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" by="title" order="desc"><r:title /> </r:feed:entries:each>').as("Riemann Dances at Raves Resurrecting feed_tools, part 2 Resurrecting feed_tools RedCloth 4 vs. CodeHighlighter Raleigh RubyCamp Logo Nominate your Ruby Hero! Iteration in herml Getting into Erlang, Playing Telephone Content Management That Won't Rot Your Brain Code Highlighting for Erlang ")
    end
  end
  
  describe "<r:feed:entries:each:title>" do
    it "should render the title" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:title /></r:feed:entries:each>').as("Nominate your Ruby Hero!")
    end
  end
  
  describe "<r:feed:entries:each:author>" do
    it "should render the author" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:author /></r:feed:entries:each>').as("Sean Cribbs")
    end
  end
  
  describe "<r:feed:entries:each:url>" do
    it "should render the URL" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:url /></r:feed:entries:each>').as("http://seancribbs.com/tech/2009/02/26/nominate-your-ruby-hero/")
    end
  end

  # TODO: We need another feed to properly test the summary properly
  describe "<r:feed:entries:each:summary>" do
    it "should render the summary" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:summary /></r:feed:entries:each>').as("")
    end
  end
  
  describe "<r:feed:entries:each:body>" do
    it "should render the body" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:body /></r:feed:entries:each>').as("<p>Is there someone who has made your Ruby experience great?  Someone who doesn&#8217;t get the recognition they deserve?  The Rails Envy guys are doing the Ruby Hero awards again, so go nominate someone!</p>\n<p><a href=\"http://www.RubyHeroes.com\" title=\"Ruby Heroes\"><img alt=\"Ruby Heroes\" src=\"http://rubyheroes.morphexchange.com/images/rubyhero_button_small.png\" /></a></p>")
    end
  end
  
  describe "<r:feed:entries:each:date>" do
    it "should render the date" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:date /></r:feed:entries:each>').as("Thu Feb 26 02:30:46 2009")
    end
    
    it "should render the date with the given format" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:date format="%Y-%m-%d"/></r:feed:entries:each>').as("2009-02-26")
    end
  end
  
  describe "<r:feed:entries:each:link>" do
    it "should render a link to the entry" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:link /></r:feed:entries:each>').as('<a href="http://seancribbs.com/tech/2009/02/26/nominate-your-ruby-hero/">Nominate your Ruby Hero!</a>')
    end
    
    it "should render a link to the entry with the contained text" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:link>This is a link</r:link></r:feed:entries:each>').as('<a href="http://seancribbs.com/tech/2009/02/26/nominate-your-ruby-hero/">This is a link</a>')
    end
    
    it "should render a link with extra attributes" do
      @page.should render('<r:feed:entries:each url="http://seancribbs.com/atom.xml" limit="1"><r:link class="foo">This is a link</r:link></r:feed:entries:each>').as('<a href="http://seancribbs.com/tech/2009/02/26/nominate-your-ruby-hero/" class="foo">This is a link</a>')
    end
  end
end