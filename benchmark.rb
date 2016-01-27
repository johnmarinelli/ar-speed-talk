require 'benchmark'
require_relative 'models'

#
# For each user, display their posts 
#
def print_header(txt)
  str = [
  '=============================================================',
  txt,
  '============================================================='
  ].join "\n"
  print str + "\n"
end

print_header 'EAGER LOADING'
# No eager loading
Benchmark.bm(10) do |x|
  x.report("Without eager loading") {
    u = User.where :id => 1..10
    u.each { |u| u.posts.each { |p| p.body } }
  }
end

# Eager loading
# performs about 700% quicker than not eager loading
Benchmark.bm(10) do |x|
  x.report("With eager loading") {
    User.where(:id => 1..10)
        .includes(:posts)
        .each { |u| u.posts.each { |p| p.body } }
  }
end


print_header 'RUBY VS SQL: PART 1'
#
# Sort a users' articles by title
# (Do database work in the database)
# 
#
# Rubyesque way
Benchmark.bm(10) do |x|
  x.report("Using idiomatic Ruby") {
    User.first.articles.sort { |a, b| a.title <=> b.title }
  }
end

# SQL version (without leaving OO abstraction)
# performs about 300% quicker
Benchmark.bm(10) do |x|
  x.report("Using ORM generated SQL") {
    User.first.articles.order :title
  }
end

print_header 'RUBY VS SQL: PART 2'
#
# Count # of posts made by user
# (Do database work in the database)
#
# Rubyesque way
Benchmark.bm(10) do |x|
  x.report("Using idiomatic Ruby") {
    User.where(:id => 1)
        .includes(:posts)
        .map { |u| u.posts.count }
        .reduce :+
  }
end

# SQL version leaves OO abstraction somewhat
# performs about 200% quicker
Benchmark.bm(10) do |x|
  x.report("Using SQL") {
    User.count_by_sql ["SELECT COUNT(*) FROM users JOIN posts ON users.id = posts.user_id WHERE users.id = 1"]
  }
end
