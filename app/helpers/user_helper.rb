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
      image_tag user.banner, class: "img-fluid", id: "banner"
    else
      image_tag "default_banner.jpg", class: "img-fluid", id: "banner"
    end
  end
end
