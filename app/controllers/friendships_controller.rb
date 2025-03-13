class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @friendship = Friendship.find(params[:id])
    redirect_back(fallback_location: root_path) if @friendship.destroy
  end
  
  def create
    @user = User.friendly.find(params[:user_id])
    @friendship = current_user.friendships.new(friend_id: @user.id)
    if @friendship.save
      notify(@user, @friendship)
      redirect_back(fallback_location: root_path)
    end
  end

  private

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
