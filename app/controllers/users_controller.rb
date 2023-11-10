class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @posts = @user.authored_posts
  end

  def destroy
    current_user.destroy
    redirect_to new_user_session_path, status: :see_other
  end
end
