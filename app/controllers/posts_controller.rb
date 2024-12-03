class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :like, :unlike]

  def home
    if params[:query].present?
      @pagy, @posts = pagy_countless(current_user.timeline.search_post(params[:query]), items: 10)
    else
      @pagy, @posts = pagy_countless(current_user.timeline, items: 10)
    end
    
    @post = current_user.authored_posts.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end


  def index
    posts = Post.all

    if params[:query].present?
      posts = Post.all.search_post(params[:query])
    end

    case params[:sort_by]
    when 'newest'
      posts = posts.order(created_at: :desc)
    when 'oldest'
      posts = posts.order(created_at: :asc)
    when 'most_liked'
      posts = posts.order(likeable_count: :desc)
    end

    @pagy, @posts = pagy_countless(posts, items: 10)
    @post = current_user.authored_posts.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def show
    @comment = @post.comments.build
    
    @cursor = (params[:cursor] || "0").to_i
    if(@cursor == 0)
      @comments = @post.comments.where.not(id: nil).where("id > ?", @cursor).take(10)
    else
      @comments = @post.comments.where.not(id: nil).where("id < ?", @cursor).take(10)
    end

    @next_cursor = @comments.last&.id
    @more_pages = @next_cursor.present? && @comments.count == 10
    render "scrollable_list" if params[:cursor]
  end

  def create
    @post = current_user.authored_posts.new(post_params)
    redirect_to @post if @post.save
  end

  def edit
    @post = Post.friendly.find(params[:id])
  end

  def update
    @post = Post.friendly.find(params[:id])
    if @post.update(post_params)
      redirect_to post_path(@post)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.friendly.find(params[:id])
    @post.destroy
    case URI(request.referer).path
      when '/posts'
        redirect_to posts_path
      when '/'
        redirect_to root_path
      else
        redirect_to user_path(current_user)
    end
  end

  def like
    like = current_user.likes.create(likeable: @post)
    notify(@post.author, like)
    render partial: "likes/post_buttons", locals: { post: @post }
  end

  def unlike
    current_user.likes.find_by(likeable: @post).destroy
    render partial: "likes/post_buttons", locals: { post: @post }
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def notify(recipient, post)
    return unless recipient != current_user

    Notification.create(user_id: recipient.id, sender_id: current_user.id, notifiable: post)
  end
end
