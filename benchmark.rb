require 'benchmark'
require_relative 'models'

p 'Measuring.....'

Benchmark.bm(10) do |x|
  x.report {
    u = User.first
    ps = u.posts
    ps.each { |p| p.body }
  }
end


Benchmark.bm(10) do |x|
  x.report {
    u = User.where(:id => 1).includes(:posts)
    ps = u.first.posts
    ps.each { |p| p.body }
  }
end
