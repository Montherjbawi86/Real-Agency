module Dashboard
  class CarsController < Dashboard::BaseController
    def index
      @cars = current_user.cars.includes(:city)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @cars = @cars.where("title ILIKE :q OR brand ILIKE :q OR car_model ILIKE :q", q: q)
      end

      @cars = @cars.where(status: params[:status]) if params[:status].present?

      @cars = case params[:sort]
      when "price_high" then @cars.order(price: :desc)
      when "price_low"  then @cars.order(price: :asc)
      when "oldest"     then @cars.order(created_at: :asc)
      else                   @cars.order(created_at: :desc)
      end

      @counts = {
        all:       current_user.cars.count,
        draft:     current_user.cars.where(status: :draft).count,
        published: current_user.cars.where(status: :published).count,
        rented:    current_user.cars.where(status: :rented).count,
        sold:      current_user.cars.where(status: :sold).count
      }
    end
  end
end
