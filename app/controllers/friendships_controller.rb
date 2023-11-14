class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @friendships = Friendship.where(user_id: params[:user_id])
  end

  def destroy
    @friendship = Friendship.find(params[:id])
    @friendship.destroy
    redirect_to root_path
  end
  
  def create
    @user = User.find(params[:user_id])
    @friendship = current_user.friendships.new(friend_id: @user.id)
    redirect_to root_path if @friendship.save
  end
end
