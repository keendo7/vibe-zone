class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    begin
      @user = User.friendly.find(params[:id])
      @pagy, @posts = pagy_countless(@user.authored_posts, items: 10)

      respond_to do |format|
        format.turbo_stream
        format.html
      end

    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, notice: "User not found"
      return
    end

    if @user != current_user
      @friendship = current_user.friendships.where(friend_id: @user.id).first
      @mutual_friends_count = current_user.mutual_friends(@user).count
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to @user
    else
      flash[:alert] = @user.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def search
    @users = User.search(params[:query])
  end

  def destroy
    current_user.destroy
    redirect_to new_user_session_path, status: :see_other
  end

  private

  def set_user
    @user = User.friendly.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :avatar)
  end
end
