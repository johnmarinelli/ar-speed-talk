require_relative 'create_tables'

def migrate_up
  CreateUsersTable.migrate :up
  CreateArticlesTable.migrate :up
  CreatePostsTable.migrate :up
end
