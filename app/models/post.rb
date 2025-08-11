class Post < ApplicationRecord
  extend FriendlyId

  IMAGE_CONTENT_TYPES = ["image/jpeg", "image/gif", "image/webp", "image/png", "image/bmp"].freeze

  friendly_id :post_identifier, use: :slugged
  belongs_to :author, class_name: 'User'
  has_many :comments, -> { includes(:commenter).order(created_at: :desc) }, as: :commentable, dependent: :destroy, inverse_of: :commentable
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_one_attached :image

  validates :content, length: { in: 3..200 }
  validates :image, content_type: IMAGE_CONTENT_TYPES, size: { less_than: 5.megabytes }
  
  scope :search_post, ->(query) { where("content ILIKE ?", "%#{query}%" ) }
  scope :descending, -> { order(created_at: :desc) }

  def to_param
    slug
  end

  def image_variant
    image.variant(
      format: :webp,
      resize_to_limit: [800, 800],
      loader: {n: -1},
      saver: {
        subsample_mode: "on",
        strip: true,
        interlace: true,
        lossless: true,
        quality: 80
      }
    ).processed
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
