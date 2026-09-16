module Dashboard
  class MaintenancesController < Dashboard::BaseController
    before_action :set_maintenance, only: [:edit, :update, :destroy, :complete]

    def index
      @maintenances = current_user.maintenances.includes(:maintainable).order(performed_on: :desc)
    end

    def new
      @maintenance = current_user.maintenances.new(currency: "SYP", performed_on: Date.current)
    end

    def create
      @maintenance = current_user.maintenances.new(maintenance_params)
      if @maintenance.save
        redirect_to dashboard_maintenances_path, notice: "تم إضافة الصيانة"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @maintenance.update(maintenance_params)
        redirect_to dashboard_maintenances_path, notice: "تم تحديث الصيانة"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @maintenance.destroy
      redirect_to dashboard_maintenances_path, notice: "تم حذف الصيانة"
    end

    def complete
      @maintenance.update(status: :completed)
      redirect_to dashboard_maintenances_path, notice: "تم إكمال الصيانة"
    end

    private

    def set_maintenance = @maintenance = current_user.maintenances.find(params[:id])

    def maintenance_params
      params.require(:maintenance).permit(:maintainable_id, :maintainable_type, :title, :description,
                                          :cost, :currency, :performed_on, :next_due_on, :kind, :status, :parts)
    end
  end
end
