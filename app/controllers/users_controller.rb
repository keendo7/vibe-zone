class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :update]

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
    if @user.update(user_params)
      flash[:success] = "User updated successfully"
      redirect_to @user
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      @user.reload
      render :edit, status: :unprocessable_entity
    end
  end

  def update_avatar
    current_user.avatar.attach(params[:avatar])

    respond_to do |format|
      format.turbo_stream do
        flash.now[:success] = t('messages.user.avatar_updated')
        render turbo_stream: [
          turbo_stream.replace("user_avatar", partial: "users/avatar_container", locals: { user: current_user}),
          turbo_stream.update("flash", partial: "layouts/flash")  
        ]
      end
      format.html { redirect_back_or_to root_path }
    end
  end

  def remove_avatar
    current_user.avatar.purge

    respond_to do |format|
      format.turbo_stream do
        flash.now[:success] = t('messages.user.avatar_removed')
        render turbo_stream: [
          turbo_stream.replace("user_avatar", partial: "users/avatar_container", locals: { user: current_user }),
          turbo_stream.update("flash", partial: "layouts/flash")
        ]
      end
      format.html { redirect_back_or_to root_path }
    end
  end

  def remove_banner
    current_user.banner.purge

    respond_to do |format|
      format.turbo_stream do
        flash.now[:success] = "Banner successfully removed"
        render turbo_stream: [
          turbo_stream.replace("user_banner", partial: "users/banner", locals: { user: current_user }),
          turbo_stream.update("flash", partial: "layouts/flash")
        ]
      end
      format.html { redirect_back_or_to root_path }
    end
  end

  def update_banner
    current_user.banner.attach(params[:banner])

    respond_to do |format|
      format.turbo_stream do
        flash.now[:success] = "Banner updated successfully"
        render turbo_stream: [
          turbo_stream.replace("user_banner", partial: "users/banner", locals: { user: current_user }),
          turbo_stream.update("flash", partial: "layouts/flash")
        ]
      end
      format.html { redirect_back_or_to root_path }
    end
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
    redirect_back_or_to root_path, alert: t('errors.user.not_found')
  end

  def set_friendship_data
    @status, @friendship = current_user.friendship_status_with(@user)
    @mutual_friends_count = current_user.mutual_friends(@user).count
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :avatar, :banner)
  end
end
