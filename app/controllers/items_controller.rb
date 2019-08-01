class ItemsController < ApplicationController
  # automagically find the item
  before_action :set_item, only: [:show, :update, :destroy]

  # GET /items
  def index
    render json: Item.all
  end

  # POST /items
  def create
    item = Item.create! item_params

    render json: item, status: 201
  end

  # GET /items/:id
  def show
    render json: @item
  end

  # PUT /items/:id
  def update
    @item.update(item_params)
    head :no_content
  end

  # PUT /items/order
  def order
    @item = Item.find params[:itemId]

    if @item.stockQty > 0
      @item.decrement!(:stockQty)
      head :no_content
    else
      render plain: 'Item is out of stock', status: 400
    end
  end

  # DELETE /items/:id
  def destroy
    @item.destroy
    head :no_content
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { message: e.message }, status: 404
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { message: e.message }, status: 400
  end

  private

  def item_params
    params.permit :description, :price, :stockQty
  end

  def order_params
    params.permit :id, :itemId, :description, :customerId, :price, :award, :total
  end

  def set_item
    @item = Item.find params[:id]
  end

end