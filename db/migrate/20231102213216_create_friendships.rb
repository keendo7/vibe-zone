class CreateFriendships < ActiveRecord::Migration[7.0]
  def change
    create_table :friendships do |t|
      t.bigint :user_id
      t.bigint :friend_id
      t.timestamps
    end
  end
end
