module UserHelper
  def user_avatar(user)
    if user.avatar.attached?
      user.avatar
    else
      user.gravatar_url
    end
  end
end
