class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_property, only: [:show, :edit, :update, :destroy, :publish, :mark_rented, :mark_sold]
  before_action :authorize_agent!, only: [:new, :create]
  before_action :authorize_owner!,  only: [:edit, :update, :destroy, :publish, :mark_rented, :mark_sold]

  def index
    @properties = Property.published.includes(:city, :user, :building, cover_image_attachment: :blob).recent

    if params[:q].present?
      q = "%#{params[:q].strip}%"
      @properties = @properties.where("title ILIKE :q OR description ILIKE :q OR address ILIKE :q", q: q)
    end

    @properties = @properties.where(city_id: params[:city_id])         if params[:city_id].present?
    @properties = @properties.where(property_type: params[:type])      if params[:type].present?
    @properties = @properties.where(listing_type: params[:listing])    if params[:listing].present?
    @properties = @properties.where("price >= ?", params[:min_price])  if params[:min_price].present?
    @properties = @properties.where("price <= ?", params[:max_price])  if params[:max_price].present?
    @properties = @properties.where("size >= ?",  params[:min_size])   if params[:min_size].present?
    @properties = @properties.where("size <= ?",  params[:max_size])   if params[:max_size].present?
    @properties = @properties.where("rooms >= ?", params[:min_rooms])  if params[:min_rooms].present?
    @properties = @properties.where("bathrooms >= ?", params[:min_bathrooms]) if params[:min_bathrooms].present?
    @properties = @properties.where(currency: params[:currency])       if params[:currency].present?

    @properties = case params[:sort]
    when "price_asc"  then @properties.order(price: :asc)
    when "price_desc" then @properties.order(price: :desc)
    when "size_asc"   then @properties.order(size: :asc)
    when "size_desc"  then @properties.order(size: :desc)
    else                   @properties.order(created_at: :desc)
    end

    @cities = City.order(:name_ar)
  end

  def show; end

  def new
    @property = current_user.properties.new
    @property.building_id = params[:building_id] if params[:building_id].present?
  end

  def create
    @property = current_user.properties.new(property_params)
    if @property.save
      redirect_to @property, notice: "تم إنشاء العقار بنجاح"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @property.update(property_params)
      redirect_to @property, notice: "تم تحديث العقار"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy
    redirect_to properties_path, notice: "تم حذف العقار"
  end

  def publish
    @property.published!
    redirect_to @property, notice: "تم نشر العقار"
  end

  def mark_rented
    @property.rented!
    redirect_to @property, notice: "تم تحديد العقار كمؤجّر"
  end

  def mark_sold
    @property.sold!
    redirect_to @property, notice: "تم تحديد العقار كمُباع"
  end

  private

  def set_property = @property = Property.find(params[:id])

  def authorize_agent!
    unless current_user&.property_agent?
      redirect_to root_path, alert: "فقط وكلاء العقارات يمكنهم إضافة عقارات"
    end
  end

  def authorize_owner!
    unless @property.user == current_user
      redirect_to root_path, alert: "غير مصرح لك"
    end
  end

  def property_params
    permitted = [
      :title, :description, :property_type, :listing_type,
      :price, :currency, :size, :floor, :total_floors,
      :rooms, :bathrooms, :address, :city_id, :status,
      :latitude, :longitude,
      :building_id, :unit_number, :unit_label, :youtube_url,
      :cover_image,
      images: []
    ] + Property::AMENITIES.keys

    params.require(:property).permit(*permitted)
  end
end
