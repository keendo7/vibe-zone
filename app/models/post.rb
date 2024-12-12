class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :post_identifier, use: :slugged
  default_scope { order(created_at: :desc) }  
  belongs_to :author, class_name: 'User'
  has_many :comments, -> {order(created_at: :desc) }, as: :commentable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  validates :content, length: { in: 3..200 }
  
  scope :search_post, ->(query) { where("content ILIKE ?", "%#{query}%" ) } 

  def to_param
    slug
  end

  private

  def post_identifier
    identifier = ""
    while true
      identifier = SecureRandom.hex 4
      continue if Post.exists?(slug: identifier)
      return identifier
    end
  end
end
