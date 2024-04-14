class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.bigint :user_id, null: false
      t.references :notifiable, polymorphic: true, null: false
      t.boolean :was_read, default: :false

      t.timestamps
    end
  end
end
