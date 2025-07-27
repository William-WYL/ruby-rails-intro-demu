class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @products = Product.all

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    if params[:search].present?
      keyword = params[:search].strip
      # ILIKE for PostgreSQL，LIKE for MySQL
      @products = @products.where("title ILIKE ? OR description ILIKE ?", "%#{keyword}%", "%#{keyword}%")
    end

    @products = @products.page(params[:page]).per(6)
  end

  def show
    @product = Product.find(params[:id])
  end
end
