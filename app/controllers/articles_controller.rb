class ArticlesController < ApplicationController

  if Rails.env == 'development'
    skip_before_action :verify_authenticity_token
  end

  def index
    articles = Article.find_by_sql("SELECT name,content,articles.created_at,articles.id FROM articles
  INNER JOIN users ON articles.user_id = users.id")
    new_articles = []
    articles.each do |article|
      new_articles.push({:id => article.id,:content=>article.content,:comments=>article.comments,:name=>article.name,:created_at=>article.created_at})
    end
  #   articles = Article.joins(:comments)
    render :json => new_articles.to_json

  end

  def create
    @article = Article.new(article_params)
    user_id = session[:current_user_id]
    user = user_id ? User.find(user_id):nil
    unless user
      render :json=>{:msg => 'no such user'}.to_json
      return
    end
    @article.user_id = user_id
    if @article.save
      render :json=>{:msg => 'success',:artical_id => @article.id}.to_json
    else
      render :json=>{:msg => 'fail'}.to_json
    end
  end

  def article_params
    params.require(:article).permit(:content)
  end
end
