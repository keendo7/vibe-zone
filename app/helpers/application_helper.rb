module ApplicationHelper
  include Pagy::Frontend

  def unfriend_button(friendship, status)
    return unless status == :friend

    button_to(
      'Unfriend',
      friendship_path(friendship),
      method: :delete,
      data: { turbo: false }
    )
  end

  def befriend_button(user, status)
    return unless status == :no_friendship

    button_to(
      'Befriend',
      friendships_path(user_id: user.id),
      method: :post,
      data: { turbo: false }
    )
  end

  def accept_request_button(friendship, status = :request)
    return unless status == :request

    button_to(
      "Accept",
      friendships_path(user_id: friendship.user.id),
      method: :post, 
      data: { turbo: false }
    )
  end

  def decline_request_button(friendship, status = :request)
    return unless status == :request

    button_to(
      "Decline",
      decline_friendship_path(friendship),
      method: :delete, 
      data: { turbo: false }
    )
  end
end
