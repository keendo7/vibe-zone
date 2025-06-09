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
      image_tag user.banner, id: "banner", class: "img-fluid"
    else
      content_tag :div, '', class: 'w-100 h-100 bg-dark bg-gradient', id: "banner", class: "img-fluid"
    end
  end
end
