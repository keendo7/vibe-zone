class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true, counter_cache: :commentable_count
  belongs_to :commenter, class_name: 'User'
  belongs_to :parent, class_name: 'Comment', foreign_key: :parent_id, optional: true
  
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :replies, -> { includes(:commenter, :commentable).order(created_at: :desc) }, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy
  
  validates :content, length: { in: 1..250 }

  scope :of_parents, -> { where(parent: nil) }

  def is_a_reply?
    !self.parent_id.nil?
  end

  def message
    if self.is_a_reply?
      " replied to your comment" 
    else
      " commented on your #{commentable_type.downcase}"
    end
  end
end
