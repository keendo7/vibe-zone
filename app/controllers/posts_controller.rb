class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :like, :unlike, :destroy, :edit]

  def home
    posts = current_user.timeline

    if params[:query].present?
      posts = posts.search_post(params[:query])
    end

    @pagy, @posts = pagy_countless(
      params[:sort_by] ? sort_by(posts, params[:sort_by]) : posts, 
      items: 10
    )

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def index
    posts = Post.includes(:author).all.descending

    if params[:query].present?
      posts = posts.search_post(params[:query])
    end

    @pagy, @posts = pagy_countless(
      params[:sort_by] ? sort_by(posts, params[:sort_by]) : posts, 
      items: 10
    )

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def show
    @comment = @post.comments.build
    @pagy, @comments = pagy_countless(
      params[:sort_by] ? sort_by(@post.comments.of_parents, params[:sort_by]) : @post.comments.of_parents,
      items: 10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @post = current_user.authored_posts.new(post_params)
    @post.image.attach(params[:post][:image])
    if @post.save
      respond_to do |format|
        format.html { redirect_to @post } 
      end
    else
      flash[:alert] = @post.errors.full_messages.join(', ')
      redirect_back fallback_location: root_path
    end
  end

  def update
    @post = Post.friendly.find(params[:id])
    if @post.update(post_params)
      respond_to do |format|
        format.html { redirect_to @post }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@post), @post) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy

    if referer_path == post_path(@post)
      redirect_to root_path, notice: "Post was successfully deleted"
    else
      redirect_back fallback_location: root_path, notice: "Post was successfully deleted"
    end
  end

  def like
    like = current_user.likes.create(likeable: @post)
    notify(@post.author, like) if like.persisted?

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
          dom_id(@post, :likes),
          partial: "posts/buttons",
          locals: { post: @post }
        )
      }  
      format.html { render partial: "posts/buttons", locals: { post: @post } }
    end
  end

  def unlike
    current_user.likes.find_by(likeable: @post)&.destroy
    @post.reload
    
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
          dom_id(@post, :likes),
          partial: "posts/buttons",
          locals: { post: @post }
        )
      }
      format.html { render partial: "posts/buttons", locals: { post: @post } }
    end
  end

  private

  def post_params
    params.require(:post).permit(:content, :image)
  end

  def set_post
  @post = Post.friendly.find(params[:id])
  rescue
    respond_to do |format|
      format.turbo_stream { 
        flash.now[:alert] = "Post doesn't exist"
        render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
      }
      format.html { redirect_to(root_path, alert: "Post doesn't exist") }
    end
  end

  def sort_by(items, params)
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
