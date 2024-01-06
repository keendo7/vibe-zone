module UserHelper
  def user_avatar(user, size=50)
    if user.avatar.attached?
      user.avatar.variant(resize_to_fill: [size, nil])
    else
      user.gravatar_url
    end
  end
end
