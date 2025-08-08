class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]

  def show
    @pagy, @posts = pagy_countless(@user.authored_posts, items: 10)
    set_friendship_data if @user != current_user
    
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
      redirect_to @user
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      @user.reload
      render :edit, status: :unprocessable_entity
    end
  end

  def update_avatar
    @user = current_user
    @user.avatar.attach(params[:avatar])

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        dom_id(@user, :avatar),
        partial: "users/avatar_container",
        locals: { user: @user }
        )
      }
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def remove_avatar
    @user = current_user
    @user.avatar.purge

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        dom_id(@user, :avatar),
        partial: "users/avatar_container",
        locals: { user: @user }
        )
      }
      format.html { redirect_back(fallback_location: root_path) }
    end
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

  def set_user
    @user = User.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_back(fallback_location: root_path, alert: t('errors.user.not_found'))
  end

  def set_friendship_data
    @status, @friendship = current_user.friendship_status_with(@user)
    @mutual_friends_count = current_user.mutual_friends(@user).count
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :avatar, :banner)
  end
end
