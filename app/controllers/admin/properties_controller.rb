module Admin
  class PropertiesController < Admin::BaseController
    before_action :set_property, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

    def index
      @properties = Property.includes(:user, :city, :building).order(created_at: :desc)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @properties = @properties.where("title ILIKE :q OR description ILIKE :q", q: q)
      end

      @properties = @properties.where(status: params[:status]) if params[:status].present?
      @properties = @properties.where(city_id: params[:city_id]) if params[:city_id].present?

      @counts = {
        all:       Property.count,
        draft:     Property.where(status: :draft).count,
        published: Property.where(status: :published).count,
        rented:    Property.where(status: :rented).count,
        sold:      Property.where(status: :sold).count
      }
      @cities = City.order(:name_ar)
    end

    def show; end

    def edit; end

    def update
      if @property.update(property_params)
        redirect_to admin_property_path(@property), notice: "✅ تم تحديث العقار"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @property.destroy
      redirect_to admin_properties_path, notice: "تم حذف العقار"
    end

    def publish
      @property.update(status: :published)
      redirect_to admin_property_path(@property), notice: "✅ تم نشر العقار"
    end

    def unpublish
      @property.update(status: :draft)
      redirect_to admin_property_path(@property), notice: "⏸️ تم إلغاء نشر العقار"
    end

    private

    def set_property = @property = Property.find(params[:id])

    def property_params
      params.require(:property).permit(
        :title, :description, :property_type, :listing_type,
        :price, :currency, :size, :floor, :total_floors,
        :rooms, :bathrooms, :address, :city_id, :status
      )
    end
  end
end
