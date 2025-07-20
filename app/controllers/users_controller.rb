class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]

  def show
    @pagy, @posts = pagy_countless(@user.authored_posts, items: 10)

    if @user != current_user
      @status, @friendship = current_user.friendship_status_with(@user)
      @mutual_friends_count = current_user.mutual_friends(@user).count
    end
      
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      purge_avatar if params[:user][:purge_avatar] == '1'
      redirect_to @user
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      @user.reload
      render :edit, status: :unprocessable_entity
    end
  end

  def update_avatar
    current_user.avatar.attach(params[:user][:avatar])
  end

  def remove_banner
    current_user.banner.purge
    redirect_to current_user
  end

  def update_banner
    current_user.banner.attach(params[:user][:banner])
  end

  def search
    users = User.search(params[:query])

    @pagy, @users = pagy_countless(users, items: 15)
  end

  def destroy
    current_user.destroy
    redirect_to new_user_session_path, status: :see_other
  end

  private

  def purge_avatar
    @user.avatar.purge
  end

  def set_user
    @user = User.friendly.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :avatar, :banner)
  end
end
