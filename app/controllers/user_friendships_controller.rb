class UserFriendshipsController < FriendshipsController
  def index
    @user = User.friendly.find(params[:user_id])
   
    if params[:query].present?
      @friendships = @user.active_friendships.search_friend(params[:query])
    else
      @friendships = @user.active_friendships
    end
  end

  def mutual_friends
    @user = User.friendly.find(params[:user_id])
    @mutuals = current_user.mutual_friends(@user)
  end
end
