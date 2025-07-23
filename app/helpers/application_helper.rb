module ApplicationHelper
  include Pagy::Frontend

  def unfriend_button(friendship, status)
    return unless status == :friend

    button_to(
      'Unfriend',
      friendship_path(friendship),
      method: :delete,
      data: { turbo: false },
      class: 'btn btn-danger p-2'
    )
  end

  def befriend_button(user, status)
    return unless status == :no_friendship

    button_to(
      'Befriend',
      friendships_path(user_id: user.id),
      method: :post,
      data: { turbo: false }, 
      class: 'btn btn-primary p-2'
    )
  end

  def accept_request_button(friendship, status = :request)
    return unless status == :request

    button_to(
      "Accept",
      friendships_path(user_id: friendship.user.id),
      method: :post, 
      data: { turbo_frame: "_top" },
      class: 'btn btn-success p-2'
    )
  end

  def decline_request_button(friendship, status = :request)
    return unless status == :request

    button_to(
      "Decline",
      decline_friendship_path(friendship),
      method: :delete, 
      data: { turbo_frame: "_top" },
      class: 'btn btn-danger p-2'
    )
  end

  def flash_class(level)
    case level
      when 'notice' then "alert alert-info"
      when 'success' then "alert alert-success"
      when 'error' then "alert alert-danger"
      when 'alert' then "alert alert-danger"
    end
  end
end
