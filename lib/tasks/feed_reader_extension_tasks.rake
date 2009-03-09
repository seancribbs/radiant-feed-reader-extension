namespace :radiant do
  namespace :extensions do
    namespace :feed_reader do
      
      desc "Runs the migration of the Feed Reader extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          FeedReaderExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          FeedReaderExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Feed Reader to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from FeedReaderExtension"
        Dir[FeedReaderExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(FeedReaderExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
