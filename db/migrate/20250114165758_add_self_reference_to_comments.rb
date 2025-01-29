class AddSelfReferenceToComments < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :comments, :comments, column: :parent_id
  end
end
