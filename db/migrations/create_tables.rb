require 'active_record'
class CreateUsersTable < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :location
      t.string :phone_number
      t.timestamps null: false
    end
  end
end

class CreateArticlesTable < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.belongs_to :user
      t.string :title
      t.text :body
      t.timestamps null: false
    end
  end
end

class CreatePostsTable < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.belongs_to :users
      t.belongs_to :articles
      t.text :body
      t.timestamps null: false
    end
  end
end
