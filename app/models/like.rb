class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  has_many :notifications, as: :notifiable, dependent: :destroy

  def message
    " liked your #{likeable_type.downcase}"
  end

  def is_a_comment?
    likeable_type == Comment
  end

  def is_a_post?
    likeable_type == Post
  end
end
