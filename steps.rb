require_relative 'db/migrations/do_migrate'
# create tables
migrate_up

# seed tables
`psql -d benchmark-talk -a -f seed_data.sql`


