class PostsController < ApplicationController
  before_action :set_post, only: [ :rating ]

  # POST /posts
  # Creates a new post for the specified user
  def create
    user = User.find_or_create_by(login: params[:login])
    unless user
      render json: { errors: [ "Failed to create user" ] }, status: :unprocessable_entity
      return
    end

    post = user.posts.build(post_params)

    if post.save
      render json: {
        data: {
          post: post,
          user: user
        },
        message: "Post created successfully"
      }, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /posts
  # Returns a list of posts ordered by average rating
  def index
    posts_limit = sanitized_limit
    posts = Post.with_average_ratings.limit(posts_limit)

    render json: {
      data: posts.map { |post| post_with_rating_response(post) },
      meta: {
        count: posts.size,
        limit: posts_limit
      }
    }, status: :ok
  end

  # POST /posts/:id/rating
  # Adds a rating to a specific post
  def rating
    rating = @post.ratings.build(rating_params)

    if rating.save
      avg_rating = @post.reload.ratings.average(:value)
      render json: {
        data: {
          avg_rating: avg_rating&.round(2)
        },
        message: "Rating added successfully"
      }, status: :created
    else
      render json: {
        errors: rating.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def sanitized_limit
    limit = params[:limit].to_i
    return 10 if limit <= 0
    [ limit, 1000000 ].min # Cap at 100 to prevent performance issues
  end

  def post_params
    params.require(:post).permit(:title, :body, :ip)
  end

  def rating_params
    params.require(:rating).permit(:user_id, :value)
  end

  def post_with_rating_response(post)
    {
      id: post.id,
      title: post.title,
      body: post.body,
      avg_rating: post.avg_rating&.to_f || 0.0
    }
  end
end
