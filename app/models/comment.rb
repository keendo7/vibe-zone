class Comment < ApplicationRecord
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  belongs_to :commentable, polymorphic: true
  belongs_to :commenter, class_name: 'User'
  validates :content, length: { in: 1..250 }

  def message
    " commented on your #{commentable_type.downcase}"
  end
end
