module Dashboard
  class ContractsController < Dashboard::BaseController
    before_action :set_contract, only: [:show, :edit, :update, :destroy, :pdf, :activate, :complete]

    def index
      scope = current_user.contracts.includes(:tenant, :customer, :property, :car)
      scope = scope.for_cars if current_user.car_agent?
      scope = scope.for_properties if current_user.property_agent?

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        scope = scope.joins("LEFT JOIN tenants   ON tenants.id   = contracts.tenant_id")
                     .joins("LEFT JOIN customers ON customers.id = contracts.customer_id")
                     .where("tenants.full_name ILIKE :q OR customers.full_name ILIKE :q OR CAST(contracts.id AS TEXT) ILIKE :q", q: q)
      end

      scope = scope.where(kind: params[:kind])     if params[:kind].present?
      scope = scope.where(status: params[:status]) if params[:status].present?

      scope = case params[:sort]
      when "oldest" then scope.order(created_at: :asc)
      when "amount" then scope.order(amount: :desc)
      else               scope.order(created_at: :desc)
      end

      @contracts = scope
      @counts = {
        all:    current_user.contracts.count,
        rent:   current_user.contracts.where(kind: :rent).count,
        sale:   current_user.contracts.where(kind: :sale).count,
        active: current_user.contracts.where(status: :active).count
      }
    end

    def show; end

    def new
      @contract = current_user.contracts.new(currency: "SYP", kind: :rent, status: :active)
    end

    def create
      @contract = current_user.contracts.new(contract_params)
      if @contract.save
        redirect_to dashboard_contracts_path, notice: "تم إنشاء العقد ✅"
      else
        flash.now[:alert] = @contract.errors.full_messages.join(" — ")
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @contract.update(contract_params)
        redirect_to dashboard_contracts_path, notice: "تم تحديث العقد ✅"
      else
        flash.now[:alert] = @contract.errors.full_messages.join(" — ")
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @contract.destroy
      redirect_to dashboard_contracts_path, notice: "تم الحذف"
    end

    def activate
      @contract.active!
      redirect_to dashboard_contracts_path, notice: "تم التنشيط ✅"
    end

    def complete
      @contract.completed!
      redirect_to dashboard_contracts_path, notice: "تم الإكمال ✅"
    end

    def pdf
      html = render_to_string(template: "dashboard/contracts/pdf", layout: false, formats: [:html])
      pdf = WickedPdf.new.pdf_from_string(html, encoding: "UTF-8", page_size: "A4",
              margin: { top: 10, bottom: 10, left: 10, right: 10 }, print_media_type: true)
      send_data pdf, filename: "contract-#{@contract.id}.pdf", type: "application/pdf", disposition: "inline"
    rescue => e
      redirect_to dashboard_contract_path(@contract), alert: "خطأ: #{e.message}"
    end

    private

    def set_contract = @contract = current_user.contracts.find(params[:id])

    def contract_params
      params.require(:contract).permit(
        :property_id, :car_id, :tenant_id, :customer_id,
        :kind, :start_date, :end_date, :amount, :daily_rate, :days,
        :start_odometer, :end_odometer, :currency, :status, :notes, :pdf
      )
    end
  end
end
