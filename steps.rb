require_relative 'db/migrations/do_migrate'

# install whatevers
`gem install bundler`
`bundle`

# create tables
migrate_up

# seed tables
`psql -d benchmark-talk -a -f seed_data.sql`

# run benchmark suite
`ruby benchmark.rb`


