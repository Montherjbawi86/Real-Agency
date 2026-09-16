module Dashboard
  class WorkersController < Dashboard::BaseController
    before_action :set_worker, only: [:edit, :update, :destroy, :toggle_active]

    def index
      @workers = current_user.workers.order(created_at: :desc)

      # Search
      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @workers = @workers.where(
          "full_name ILIKE :q OR phone ILIKE :q OR position ILIKE :q OR national_id ILIKE :q",
          q: q
        )
      end

      # Filter by status
      case params[:status]
      when "active"   then @workers = @workers.where(active: true)
      when "inactive" then @workers = @workers.where(active: false)
      end

      # Filter by pay type
      @workers = @workers.where(pay_type: params[:pay_type]) if params[:pay_type].present?

      # Sort
      @workers = case params[:sort]
      when "name"     then @workers.order(:full_name)
      when "salary_high" then @workers.order(salary: :desc)
      when "salary_low"  then @workers.order(salary: :asc)
      when "oldest"   then @workers.order(created_at: :asc)
      else                 @workers.order(created_at: :desc)
      end

      @counts = {
        all:      current_user.workers.count,
        active:   current_user.workers.active.count,
        inactive: current_user.workers.inactive.count
      }
    end

    def new
      @worker = current_user.workers.new(currency: "SYP", active: true, pay_type: :monthly)
    end

    def create
      @worker = current_user.workers.new(worker_params)
      if @worker.save
        redirect_to dashboard_workers_path, notice: "✅ تم إضافة العامل"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @worker.update(worker_params)
        redirect_to dashboard_workers_path, notice: "✅ تم تحديث العامل"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @worker.destroy
      redirect_to dashboard_workers_path, notice: "تم الحذف"
    end

    def toggle_active
      @worker.update(active: !@worker.active)
      redirect_to dashboard_workers_path, notice: "تم التحديث"
    end

    private

    def set_worker = @worker = current_user.workers.find(params[:id])

    def worker_params
      params.require(:worker).permit(
        :full_name, :phone, :national_id, :position, :birth_date,
        :hired_on, :address, :emergency_contact, :emergency_phone,
        :pay_type, :monthly_salary, :daily_rate, :hourly_rate,
        :overtime_multiplier, :working_hours_per_day, :working_days_per_month,
        :currency, :active
      )
    end
  end
end
