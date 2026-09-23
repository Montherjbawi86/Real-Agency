module Dashboard
  class TenantsController < Dashboard::BaseController
    before_action :set_tenant, only: [:edit, :update, :destroy, :toggle_active]
    before_action :load_properties, only: [:index]

    def index
      @tenants = current_user.tenants.includes(:property, :contracts, :payments)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @tenants = @tenants.where("full_name ILIKE :q OR phone ILIKE :q OR national_id ILIKE :q", q: q)
      end

      case params[:status]
      when "active"   then @tenants = @tenants.where(active: true)
      when "inactive" then @tenants = @tenants.where(active: false)
      end

      @tenants = @tenants.joins(:contracts).where(contracts: { kind: params[:kind] }).distinct if params[:kind].present?
      @tenants = @tenants.where(property_id: params[:property_id]) if params[:property_id].present?

      @tenants = case params[:sort]
      when "name"      then @tenants.order(:full_name)
      when "rent_high" then @tenants.order(rent_amount: :desc)
      when "rent_low"  then @tenants.order(rent_amount: :asc)
      when "oldest"    then @tenants.order(created_at: :asc)
      else                  @tenants.order(created_at: :desc)
      end

      @counts = {
        all:      current_user.tenants.count,
        active:   current_user.tenants.where(active: true).count,
        inactive: current_user.tenants.where(active: false).count
      }
    end

    def new
      @tenant = current_user.tenants.new(currency: "SYP", active: true)
    end

    def create
      @tenant = current_user.tenants.new(tenant_params)
      if @tenant.save
        redirect_to dashboard_tenants_path, notice: "تم إضافة المستأجر ✅"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @tenant.update(tenant_params)
        redirect_to dashboard_tenants_path, notice: "تم تحديث المستأجر ✅"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @tenant.destroy
      redirect_to dashboard_tenants_path, notice: "تم الحذف"
    end

    def toggle_active
      @tenant.update(active: !@tenant.active)
      redirect_to dashboard_tenants_path, notice: "تم التحديث"
    end

    private

    def set_tenant
      @tenant = current_user.tenants.find(params[:id])
    end

    def load_properties
      @in_buildings = current_user.properties.where.not(building_id: nil)
                                 .includes(:building)
                                 .group_by(&:building)
      @standalone   = current_user.properties.where(building_id: nil)
    end

    def tenant_params
      params.require(:tenant).permit(:property_id, :full_name, :phone, :national_id,
                                     :start_date, :end_date, :rent_amount, :currency, :active)
    end
  end
end
