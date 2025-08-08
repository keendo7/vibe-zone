class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:create]

  def create
    @friendship = current_user.friendships.build(friend_id: @user.id)
    
    if @friendship.save
      notify(@user, @friendship)
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    @friendship = current_user.friendships.find(params[:id])
    redirect_back(fallback_location: root_path) if @friendship.destroy
  rescue ActiveRecord::RecordNotFound
    redirect_to(root_path, alert: t('errors.friendship.not_found'))
  end

  def decline
    @friendship = current_user.received_friendships.find(params[:id])
    redirect_back(fallback_location: root_path) if @friendship.destroy
  rescue ActiveRecord::RecordNotFound
    redirect_to(root_path, alert: t('errors.friendship.not_found'))
  end
  
  private

  def set_user
    @user = User.friendly.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to(root_path, alert: t('errors.user.not_found'))
  end

  def notify(recipient, friendship)
    return unless recipient != current_user
    
    Notification.create(user_id: recipient.id, sender_id: current_user.id, notifiable: friendship)
    unless friendship.is_mutual?
      UserFriendshipRequestJob.perform_async(recipient.id, current_user.id)
    else
      UserFriendshipRequestAcceptedJob.perform_async(recipient.id, current_user.id)
    end
  end
end
