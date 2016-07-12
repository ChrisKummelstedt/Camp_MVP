class ItemsController < ApplicationController
  # GET /items
  # GET /items.json
  def index
    @inventory = Inventory.find(params[:inventory_id])
    @items = @inventory.items

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @inventory = Inventory.find(params[:inventory_id])
    @item = @inventory.items.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @inventory = Inventory.find(params[:inventory_id])
    @item = @inventory.items.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit
    @inventory = Inventory.find(params[:inventory_id])
    @item = @inventory.items.find(params[:id])
    # @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(params[:item])

    if @item.save
      respond_to do |format|
        format.html {
          render :json => [@item.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json {
          render :json => [@item.to_jq_upload].to_json
        }
      end
    else
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @inventory = Inventory.find(params[:inventory_id])
    @item = @inventory.items.find(params[:id])
    @item.update(item_params)
    @item.save

    respond_to do |format|
      if @item.update_attributes(item_params)
        format.html { redirect_to :back, notice: 'Item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    #@inventory = Inventory.find(params[:inventory_id])
    #@item = @inventory.items.find(params[:id])
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end

  def make_default
    @item = Item.find(params[:id])
    @inventory = Inventory.find(params[:inventory_id])
    @inventory.cover = @item.id
    @inventory.save

    respond_to do |format|
      format.js
    end
  end

  def claim
    @item = Item.find(params[:id])
    @item.owner << current_user
    @item.save
    flash[:notice] = "Awesome! Consider it's yours!"
    redirect_to(:back)
  end

  def unclaim
    @item = Item.find(params[:id])
    @item.owner.delete(current_user)
    @item.save
    flash[:notice] = "The item is no longer yours"
    redirect_to(:back)
  end

  def borrow
    item = Item.find(params[:item_id])

    if item.borrow_secret_key.blank?
      item.borrow(current_user)
      if item.save
        BorrowMailer.ask_owner(item).deliver_now
        notice = "Request to owner has been sent"
      else
        notice = "Something went wrong"
      end
    else
      notice = "The item already borrowed"
    end

    redirect_to(:back, notice: notice)
  end

  def borrow_processing
    item = Item.find(params[:item_id])
    secret_key = params.fetch(:borrow_secret_key, nil)
    owner_answer = params.fetch(:answer_status, nil)

    if secret_key.present? &&
       owner_answer.present? &&
       secret_key == item.borrow_secret_key
      case params[:answer_status]
      when 'accept'
        BorrowMailer.recipient_access(item.borrowed_by.last.email).deliver_now
        item.borrow_accept
        item.save
        notice = "The item has been approved"
      when 'deny'
        BorrowMailer.recipient_access(item.borrowed_by.last.email).deliver_now
        item.borrow_deny
        item.save
        notice = "The item has been rejected"
      end
    else
      notice = "Something went wrong"
    end

    redirect_to root_path, notice: notice
  end

  private

  def item_params
    params.require(:item)
          .permit(:title, :description, :inventory_id,
                  :image, :tag_list, :tag, { tag_ids: [] },
                  :tag_ids, :owner, :borrowed_by,
                  :borrow_secret_key, :borrow_status )
  end
end
