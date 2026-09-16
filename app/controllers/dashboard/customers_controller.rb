module Dashboard
  class CustomersController < Dashboard::BaseController
    before_action :set_customer, only: [:show, :edit, :update, :destroy]

    def index
      @customers = current_user.customers.includes(:contracts, :payments)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @customers = @customers.where("full_name ILIKE :q OR phone ILIKE :q OR national_id ILIKE :q", q: q)
      end

      @customers = @customers.joins(:contracts).where(contracts: { kind: params[:kind] }).distinct if params[:kind].present?

      @customers = case params[:sort]
      when "name"   then @customers.order(:full_name)
      when "oldest" then @customers.order(created_at: :asc)
      else               @customers.order(created_at: :desc)
      end

      @counts = { all: current_user.customers.count }
    end

    def show; end

    def new
      @customer = current_user.customers.new
    end

    def create
      @customer = current_user.customers.new(customer_params)
      if @customer.save
        redirect_to dashboard_customers_path, notice: "تم إضافة العميل ✅"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @customer.update(customer_params)
        redirect_to dashboard_customers_path, notice: "تم تحديث العميل ✅"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @customer.destroy
      redirect_to dashboard_customers_path, notice: "تم الحذف"
    end

    private

    def set_customer = @customer = current_user.customers.find(params[:id])

    def customer_params
      params.require(:customer).permit(:full_name, :phone, :national_id, :address, :notes)
    end
  end
end
