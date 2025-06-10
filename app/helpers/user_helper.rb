module UserHelper
  def user_avatar(user, size=50)
    if user.avatar.attached?
      user.avatar.variant(resize_to_fill: [size, nil])
    else
      user.gravatar_url
    end
  end

  def user_banner(user)
    if user.banner.attached?
      image_tag user.banner, id: 'banner', class: 'img-fluid'
    else
      image_tag "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7", class: 'bg-dark bg-gradient', id: 'banner'
    end
  end
end
