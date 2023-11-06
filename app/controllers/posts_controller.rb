class PostsController < ApplicationController
  before_action :authenticate_user!

  def home
    @posts = current_user.timeline
  end
end
