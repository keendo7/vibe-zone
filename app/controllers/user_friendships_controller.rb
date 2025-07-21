class UserFriendshipsController < FriendshipsController
  def index
    @user = User.friendly.find(params[:user_id])
   
    if params[:query].present?
      @pagy, @friendships = pagy_countless(@user.active_friendships.search_friend(params[:query]), items: 15)
    else
      @pagy, @friendships = pagy_countless(@user.active_friendships, items: 15)
    end
  end

  def mutual_friends
    @user = User.friendly.find(params[:user_id])

    if params[:query].present?
      @pagy, @mutuals = pagy_countless(current_user.mutual_friends(@user).search_friend(params[:query]), items: 15)
    else
      @pagy, @mutuals = pagy_countless(current_user.mutual_friends(@user), items: 15)
    end
  end
end
