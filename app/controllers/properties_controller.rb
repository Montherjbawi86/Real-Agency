class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_property, only: [:show, :edit, :update, :destroy, :publish, :mark_rented, :mark_sold]
  before_action :authorize_agent!, only: [:new, :create]
  before_action :authorize_owner!,  only: [:edit, :update, :destroy, :publish, :mark_rented, :mark_sold]

  def index
    @properties = Property.published.includes(:city, :user, :building, cover_image_attachment: :blob).recent
    @properties = @properties.where(city_id: params[:city_id])         if params[:city_id].present?
    @properties = @properties.where(property_type: params[:type])      if params[:type].present?
    @properties = @properties.where(listing_type: params[:listing])    if params[:listing].present?
    @properties = @properties.where(building_id: params[:building_id]) if params[:building_id].present?
    @properties = @properties.where("price <= ?", params[:max_price])  if params[:max_price].present?
  end

  def show
  end

  def new
    unless current_user.can_add_listing?
      redirect_to billing_subscription_path,
                  alert: "لقد استنفدت عدد الإعلانات المسموح بها — قم بترقية خطتك"
      return
    end
    @property = current_user.properties.new
    @property.building_id = params[:building_id] if params[:building_id].present?
  end

  def create
    unless current_user.can_add_listing?
      redirect_to billing_subscription_path,
                  alert: "لقد استنفدت عدد الإعلانات المسموح بها — قم بترقية خطتك"
      return
    end
    @property = current_user.properties.new(property_params)
    if @property.save
      redirect_to @property, notice: "تم إنشاء العقار بنجاح"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

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

  def set_property
    @property = Property.find(params[:id])
  end

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
      :building_id, :unit_number, :unit_label,
      :youtube_url,
      :cover_image,
      images: []
    ] + Property::AMENITIES.keys

    params.require(:property).permit(*permitted)
  end
end
