class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :post_identifier, use: :slugged

  belongs_to :author, class_name: 'User'
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  validates :content, length: { in: 3..200 }

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
