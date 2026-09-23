class CarsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_car, only: [:show, :edit, :update, :destroy, :publish, :mark_rented, :mark_sold]
  before_action :authorize_agent!, only: [:new, :create]
  before_action :authorize_owner!,  only: [:edit, :update, :destroy, :publish, :mark_rented, :mark_sold]

  def index
    @cars = Car.published.includes(:city, :user, cover_image_attachment: :blob).recent

    if params[:q].present?
      q = "%#{params[:q].strip}%"
      @cars = @cars.where("title ILIKE :q OR brand ILIKE :q OR car_model ILIKE :q", q: q)
    end

    @cars = @cars.where(city_id: params[:city_id])        if params[:city_id].present?
    @cars = @cars.where(brand: params[:brand])            if params[:brand].present?
    @cars = @cars.where(body_type: params[:body_type])    if params[:body_type].present?
    @cars = @cars.where(fuel_type: params[:fuel_type])    if params[:fuel_type].present?
    @cars = @cars.where(condition: params[:condition])    if params[:condition].present?
    @cars = @cars.where(transmission: params[:transmission]) if params[:transmission].present?
    @cars = @cars.where("year >= ?", params[:min_year])   if params[:min_year].present?
    @cars = @cars.where("year <= ?", params[:max_year])   if params[:max_year].present?
    @cars = @cars.where("price >= ?", params[:min_price]) if params[:min_price].present?
    @cars = @cars.where("price <= ?", params[:max_price]) if params[:max_price].present?
    @cars = @cars.where("mileage <= ?", params[:max_mileage]) if params[:max_mileage].present?
    @cars = @cars.where(currency: params[:currency])      if params[:currency].present?
    @cars = @cars.where(color: params[:color])            if params[:color].present?

    @cars = case params[:sort]
    when "price_asc"   then @cars.order(price: :asc)
    when "price_desc"  then @cars.order(price: :desc)
    when "year_desc"   then @cars.order(year: :desc)
    when "year_asc"    then @cars.order(year: :asc)
    when "mileage_asc" then @cars.order(mileage: :asc)
    else                    @cars.order(created_at: :desc)
    end

    @cities = City.order(:name_ar)
    @brands = Car.published.distinct.pluck(:brand).compact.sort
    @colors = Car.published.distinct.pluck(:color).compact.reject(&:blank?).sort
  end

  def show; end

  def new
    @car = current_user.cars.new
  end

  def create
    @car = current_user.cars.new(car_params)
    if @car.save
      redirect_to @car, notice: "تم إنشاء السيارة بنجاح"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @car.update(car_params)
      redirect_to @car, notice: "تم تحديث السيارة"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @car.destroy
    redirect_to cars_path, notice: "تم حذف السيارة"
  end

  def publish
    @car.published!
    redirect_to @car, notice: "تم نشر السيارة"
  end

  def mark_rented
    @car.rented!
    redirect_to @car, notice: "تم تحديد السيارة كمؤجّرة"
  end

  def mark_sold
    @car.sold!
    redirect_to @car, notice: "تم تحديد السيارة كمُباعة"
  end

  private

  def set_car = @car = Car.find(params[:id])

  def authorize_agent!
    unless current_user&.car_agent?
      redirect_to root_path, alert: "فقط وكلاء السيارات يمكنهم إضافة سيارات"
    end
  end

  def authorize_owner!
    unless @car.user == current_user
      redirect_to root_path, alert: "غير مصرح لك"
    end
  end

  def car_params
    permitted = [
      :title, :description, :brand, :car_model, :year,
      :price, :currency, :mileage, :fuel_type, :transmission,
      :condition, :body_type, :color, :doors, :seats,
      :engine_size, :city_id, :status,
      :latitude, :longitude, :youtube_url,
      :cover_image,
      images: []
    ] + Car::FEATURES.keys

    params.require(:car).permit(*permitted)
  end
end
