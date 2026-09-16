module Dashboard
  class BuildingsController < Dashboard::BaseController
    before_action :set_building, only: [:show, :edit, :update, :destroy, :manage_units, :bulk_create_units]

    def index
      @buildings = current_user.buildings.includes(:city, :properties).recent
    end

    def show
      @properties = @building.properties.recent
    end

    def new
      @building = current_user.buildings.new(status: :ready)
    end

    def create
      @building = current_user.buildings.new(building_params)
      if @building.save
        redirect_to manage_units_dashboard_building_path(@building), notice: "تم إنشاء البناء ✅ — أنشئ الوحدات الآن"
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

    def manage_units
      @properties = @building.properties.order(:unit_number)
    end

    # Bulk create flats — e.g. 3 floors × 4 flats = 12 units
    def bulk_create_units
      floors = params[:floors].to_i
      units  = params[:units_per_floor].to_i
      prefix = params[:prefix].presence || "A"
      price  = params[:price].to_d
      size   = params[:size].to_i
      rooms  = params[:rooms].to_i
      baths  = params[:bathrooms].to_i
      listing = params[:listing_type] || "rent"
      ptype  = params[:property_type] || "apartment"

      created = 0
      (1..floors).each do |floor|
        (1..units).each do |unit|
          number = "#{floor}#{format('%02d', unit)}"
          @building.properties.create!(
            user: current_user,
            city: @building.city,
            title: "#{@building.name} — شقة #{number}",
            description: "وحدة رقم #{number} في #{@building.name}",
            property_type: ptype,
            listing_type: listing,
            unit_number: number,
            unit_label: "شقة #{number}",
            floor: floor,
            total_floors: floors,
            price: price,
            currency: "SYP",
            size: size,
            rooms: rooms,
            bathrooms: baths,
            status: :draft
          )
          created += 1
        end
      end

      redirect_to manage_units_dashboard_building_path(@building),
                  notice: "تم إنشاء #{created} وحدة ✅"
    rescue => e
      redirect_to manage_units_dashboard_building_path(@building),
                  alert: "خطأ: #{e.message}"
    end

    private

    def set_building = @building = current_user.buildings.find(params[:id])

    def building_params
      params.require(:building).permit(
        :name, :city_id, :address, :floors_count, :units_per_floor,
        :year_built, :description, :status, :cover_image, images: []
      )
    end
  end
end
