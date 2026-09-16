module Admin
  class CarsController < Admin::BaseController
    before_action :set_car, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

    def index
      @cars = Car.includes(:user, :city).order(created_at: :desc)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @cars = @cars.where("title ILIKE :q OR brand ILIKE :q OR car_model ILIKE :q", q: q)
      end

      @cars = @cars.where(status: params[:status]) if params[:status].present?
      @cars = @cars.where(city_id: params[:city_id]) if params[:city_id].present?

      @counts = {
        all:       Car.count,
        draft:     Car.where(status: :draft).count,
        published: Car.where(status: :published).count,
        rented:    Car.where(status: :rented).count,
        sold:      Car.where(status: :sold).count
      }
      @cities = City.order(:name_ar)
    end

    def show; end

    def edit; end

    def update
      if @car.update(car_params)
        redirect_to admin_car_path(@car), notice: "✅ تم تحديث السيارة"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @car.destroy
      redirect_to admin_cars_path, notice: "تم حذف السيارة"
    end

    def publish
      @car.update(status: :published)
      redirect_to admin_car_path(@car), notice: "✅ تم نشر السيارة"
    end

    def unpublish
      @car.update(status: :draft)
      redirect_to admin_car_path(@car), notice: "⏸️ تم إلغاء نشر السيارة"
    end

    private

    def set_car = @car = Car.find(params[:id])

    def car_params
      params.require(:car).permit(
        :title, :description, :brand, :car_model, :year,
        :price, :currency, :mileage, :fuel_type, :transmission,
        :condition, :body_type, :color, :doors, :seats,
        :engine_size, :city_id, :status
      )
    end
  end
end
