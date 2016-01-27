require 'benchmark'
require 'active_support/core_ext/date'
require 'active_support/core_ext/time'
require_relative 'models'

def print_header(txt)
  str = [
  '=============================================================',
  txt,
  '============================================================='
  ].join "\n"
  print str + "\n"
end

#
# For each user, display their posts 
#
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
    User.first.articles.order(:title => :asc)
      .each { |a| a.title }
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

print_header 'RUBY VS SQL: PART 3'
#
# Average users created, per month-week
# 
# Idiomaticish Ruby.  Takes......ages
Benchmark.bm(10) do |x|
  x.report("Using Ruby") {
    def week_of_month(date)
      date = Time.parse(date.to_s)
      wk_of_target_date = date.strftime("%U").to_i
      wk_of_month_begin = date.beginning_of_month.strftime("%U").to_i
      wk_of_target_date - wk_of_month_begin 
    end

    wks_bucket = Array.new 5, 0

    User.where(:created_at => (Date.parse('2015-07-01')..Date.parse('2015-09-01')))
        .each do |u|
          wom = week_of_month(u.created_at)
          begin
            wks_bucket[wom - 1] += 1
          rescue NoMethodError => e
            p wks_bucket
            p wom
          end
        end

    wks_bucket.map! { |w| w / 2 }
  }
end

# Raw SQL.  Takes about 12 seconds
Benchmark.bm(10) do |x|
  x.report("Using Raw SQL") {
    query = "
      select right(sub.mnth_wk, 1), avg(count) from 
      (
        select left(to_char(created_at, 'MM-W-YYYY'), 4) as mnth_wk, count(*) 
        from users 
        where created_at between TIMESTAMP '2015-07-01' and timestamp '2015-09-01' 
        group by 1 
        order by 1
      ) AS sub
      group by 1 order by 1"
    ActiveRecord::Base.connection.execute query
  }
end
