require 'active_record'

class ActiveRecord::Base 
  self.establish_connection :adapter => 'postgresql', :host => 'localhost', :port => 6432, :username => 'john', :password => ENV['POSTGRES_PASSWORD'], :database => 'benchmark_talk'
end

