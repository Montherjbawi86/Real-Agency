class BuildingsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_building, only: [:show, :edit, :update, :destroy]
  before_action :authorize_agent!, only: [:new, :create]
  before_action :authorize_owner!,  only: [:edit, :update, :destroy]

  def index
    @buildings = Building.includes(:city, :properties).recent
  end

  def show
    @properties = @building.properties.published
  end

  def new
    @building = current_user.buildings.new
  end

  def create
    @building = current_user.buildings.new(building_params)
    if @building.save
      redirect_to dashboard_building_path(@building), notice: "تم إنشاء البناء ✅"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @building.update(building_params)
      redirect_to dashboard_building_path(@building), notice: "تم تحديث البناء ✅"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @building.destroy
    redirect_to dashboard_buildings_path, notice: "تم حذف البناء"
  end

  private

  def set_building = @building = Building.find(params[:id])

  def authorize_agent!
    redirect_to root_path, alert: "فقط الوكلاء" unless current_user&.property_agent?
  end

  def authorize_owner!
    redirect_to root_path, alert: "غير مصرح" unless @building.user == current_user
  end

  def building_params
    params.require(:building).permit(
      :name, :city_id, :address, :floors_count, :units_per_floor,
      :year_built, :description, :status, :cover_image, images: []
    )
  end
end
