class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @products = Product.all
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
    @products = @products.page(params[:page]).per(4)
  end

  def show
    @product = Product.find(params[:id])
  end
end
