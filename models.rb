require 'active_record'

class ActiveRecord::Base 
  self.establish_connection :adapter => 'postgresql', :host => 'localhost', :port => ENV['POSTGRES_PORT'] || 5432, :username => 'john', :password => ENV['POSTGRES_PASSWORD'], :database => 'benchmark_talk'
  #self.logger = Logger.new STDOUT
end

class User < ActiveRecord::Base
  has_many :articles
  has_many :posts
end

class Article < ActiveRecord::Base
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :article, :class_name => 'Article', :foreign_key => 'article_id'
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
end
