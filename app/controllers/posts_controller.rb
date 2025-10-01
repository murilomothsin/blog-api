class PostsController < ApplicationController
  def create
    user = User.find_or_create_by(login: params[:login])
    @post = user.posts.new(post_params)
    if @post.save
      render json: @post, status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def index
    @posts = Post.all
    render json: @posts
  end

  def rating
    @post = Post.find(params[:id])
    begin
      @post.ratings.create!(rating_params)
      render json: { acg_rating: @post.ratings.average(:value) }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :ip)
  end

  def rating_params
    params.require(:rating).permit(:user_id, :value)
  end
end
