class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true, counter_cache: :commentable_count
  belongs_to :commenter, class_name: 'User'
  belongs_to :parent, class_name: 'Comment', foreign_key: :parent_id, optional: true
  
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :replies, -> { includes(:commenter, :commentable).order(created_at: :asc) }, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy
  
  validates :content, length: { in: 1..250 }
  validate :parent_exists, if: -> { parent_id.present? }

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

  private

  def parent_exists 
    errors.add(:parent_id, "comment may have been deleted.") unless Comment.exists?(parent_id)
  end
end
