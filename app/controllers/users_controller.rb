class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @posts = @user.authored_posts

    if @user != current_user
      @friendship = current_user.friendships.where(friend_id: @user.id).first
    end
  end

  def destroy
    current_user.destroy
    redirect_to new_user_session_path, status: :see_other
  end
end
