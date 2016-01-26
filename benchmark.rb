require 'benchmark'
require_relative 'models'

p 'Measuring.....'

# No eager loading
Benchmark.bm(10) do |x|
  x.report("W/o eager loading") {
    u = User.first
    ps = u.posts
    ps.each { |p| p.body }
  }
end

# Eager loading
# performs about 700% quicker than not eager loading
Benchmark.bm(10) do |x|
  x.report("W/ eager loading") {
    u = User.where(:id => 1)
            .includes(:posts)
            .first
    ps = u.posts
    ps.each { |p| p.body }
  }
end

# Rubyesque way
Benchmark.bm(10) do |x|
  x.report("Using Ruby") {
    User.where(:id => 1)
        .includes(:posts)
        .map { |u| u.posts.count }
        .reduce :+
  }
end

# Raw SQL 
# performs about 200% quicker
Benchmark.bm(10) do |x|
  x.report("Using SQL") {
    User.count_by_sql ["SELECT COUNT(*) FROM users JOIN posts ON users.id = posts.user_id WHERE users.id = 1"]
  }
end

