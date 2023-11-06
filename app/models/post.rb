class Post < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_many :comments, as: :commentable

  validates :content, length: { in: 3..200 }
end
