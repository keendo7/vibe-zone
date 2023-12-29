module UserHelper
  def user_avatar(user)
    if user.image
      user.image
    else
      user.gravatar_url
    end
  end
end
