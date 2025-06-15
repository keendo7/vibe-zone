module ApplicationHelper
  include Pagy::Frontend

  def unfriend_button(friendship, status)
    return unless status == :friend

    button_to(
      'Unfriend',
      friendship_path(friendship),
      method: :delete,
      data: { turbo: false },
      class: 'btn btn-danger round-btn p-2'
    )
  end

  def befriend_button(user, status)
    return unless status == :no_friendship

    button_to(
      'Befriend',
      friendships_path(user_id: user.id),
      method: :post,
      data: { turbo: false }, 
      class: 'btn btn-primary round-btn p-2'
    )
  end

  def accept_request_button(friendship, status = :request)
    return unless status == :request

    button_to(
      "Accept",
      friendships_path(user_id: friendship.user.id),
      method: :post, 
      data: { turbo_frame: "_top" },
      class: 'btn btn-success round-btn p-2'
    )
  end

  def decline_request_button(friendship, status = :request)
    return unless status == :request

    button_to(
      "Decline",
      decline_friendship_path(friendship),
      method: :delete, 
      data: { turbo_frame: "_top" },
      class: 'btn btn-danger round-btn p-2'
    )
  end
end
