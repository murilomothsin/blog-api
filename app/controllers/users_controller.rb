class UsersController < ApplicationController
  def index
    @ips_with_authors = Post.group(:ip)
      .joins("LEFT JOIN users ON users.id = posts.user_id")
      .having("COUNT(DISTINCT user_id) > 1")
      .pluck(:ip, Arel.sql("ARRAY_AGG(DISTINCT users.login)"))
      .map { |ip, logins| { ip: ip, author_logins: logins } }

      render json: @ips_with_authors
  end
end
