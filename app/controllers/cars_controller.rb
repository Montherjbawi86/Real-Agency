class CarsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_car, only: [:show, :edit, :update, :destroy, :publish, :mark_rented, :mark_sold]
  before_action :authorize_agent!, only: [:new, :create]
  before_action :authorize_owner!,  only: [:edit, :update, :destroy, :publish, :mark_rented, :mark_sold]

  def index
    @cars = Car.published.includes(:city, :user, cover_image_attachment: :blob).recent
    @cars = @cars.where(city_id: params[:city_id])        if params[:city_id].present?
    @cars = @cars.where(brand: params[:brand])            if params[:brand].present?
    @cars = @cars.where(body_type: params[:body_type])    if params[:body_type].present?
    @cars = @cars.where(fuel_type: params[:fuel_type])    if params[:fuel_type].present?
    @cars = @cars.where(condition: params[:condition])    if params[:condition].present?
    @cars = @cars.where("price <= ?", params[:max_price]) if params[:max_price].present?

    if params[:q].present?
      q = "%#{params[:q].strip}%"
      @cars = @cars.where("title ILIKE :q OR brand ILIKE :q OR car_model ILIKE :q", q: q)
    end

    @cars = case params[:sort]
    when "price_high" then @cars.order(price: :desc)
    when "price_low"  then @cars.order(price: :asc)
    when "year_new"   then @cars.order(year: :desc)
    when "mileage"    then @cars.order(mileage: :asc)
    else                   @cars.recent
    end

    @brands = Car.published.distinct.pluck(:brand).compact.sort
  end

  def show
  end

  def new
    unless current_user.can_add_listing?
      redirect_to billing_subscription_path,
                  alert: "لقد استنفدت عدد الإعلانات المسموح بها — قم بترقية خطتك"
      return
    end
    @car = current_user.cars.new
  end

  def create
    unless current_user.can_add_listing?
      redirect_to billing_subscription_path,
                  alert: "لقد استنفدت عدد الإعلانات المسموح بها — قم بترقية خطتك"
      return
    end
    @car = current_user.cars.new(car_params)
    if @car.save
      redirect_to @car, notice: "تم إنشاء السيارة بنجاح"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

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
      :latitude, :longitude,
      :youtube_url,
      :cover_image,
      images: []
    ] + Car::FEATURES.keys

    params.require(:car).permit(*permitted)
  end
end
