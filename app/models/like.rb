class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :user_id, uniqueness: { scope: [:likeable_id, :likeable_type], message: 'can only like this item once' }

  def message
    " liked your #{likeable_type.downcase}"
  end

  def is_a_comment?
    likeable_type == "Comment"
  end

  def is_a_post?
    likeable_type == "Post"
  end
end
