class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.friendly.find(params[:user_id])
    @friendships = @user.friendships
  end

  def notifications
    @received_friendships = current_user.received_friendships
  end

  def destroy
    @friendship = Friendship.find(params[:id])
    current_user.remove_friendship(@friendship)
    redirect_to root_path
  end
  
  def create
    @user = User.find(params[:user_id])
    @friendship = current_user.friendships.new(friend_id: @user.id)
    redirect_to root_path if @friendship.save
  end
end
