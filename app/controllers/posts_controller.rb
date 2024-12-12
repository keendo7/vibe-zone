class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :like, :unlike]

  def home
    posts = current_user.timeline

    if params[:query].present?
      posts = current_user.timeline.search_post(params[:query])
    end

    @pagy, @posts = pagy_countless(
      params[:sort_by] ? content_posts(posts, params[:sort_by]) : posts, 
      items: 10
    )
    
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

    @pagy, @posts = pagy_countless(
      params[:sort_by] ? content_posts(posts, params[:sort_by]) : posts, 
      items: 10
    )

    @post = current_user.authored_posts.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def show
    @comment = @post.comments.build
    @pagy, @comments = pagy_countless(
      params[:sort_by] ? content_posts(@post.comments, params[:sort_by]) : @post.comments,
      items: 10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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
    @post.reload
    render partial: "likes/post_buttons", locals: { post: @post }
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def content_posts(items, params)
    case params
    when 'newest'
      return items.reorder(created_at: :desc)
    when 'oldest'
      return items.reorder(created_at: :asc)
    when 'most_liked'
      return items.reorder(likeable_count: :desc)
    when 'most_popular'
      return items.reorder(commentable_count: :desc)
    end
  end

  def notify(recipient, post)
    return unless recipient != current_user

    Notification.create(user_id: recipient.id, sender_id: current_user.id, notifiable: post)
  end
end
