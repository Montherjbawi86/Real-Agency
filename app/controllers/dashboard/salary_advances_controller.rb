module Dashboard
  class SalaryAdvancesController < Dashboard::BaseController
    before_action :set_worker,   only: [:index, :new, :create]
    before_action :set_advance,  only: [:destroy]

    def index
      if @worker
        @advances = @worker.salary_advances.recent
      else
        @advances = current_user.salary_advances.includes(:worker).recent
      end
    end

    def new
      @advance = @worker.salary_advances.new(
        user:          current_user,
        advance_date:  Date.current,
        currency:      @worker.currency,
        amount:        0
      )
    end

    def create
      @advance = current_user.salary_advances.new(advance_params)
      @advance.worker = @worker
      if @advance.save
        redirect_to dashboard_worker_salary_advances_path(@worker),
                    notice: "✅ تم تسجيل السلفة"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      worker = @advance.worker
      @advance.destroy
      redirect_back fallback_location: dashboard_worker_salary_advances_path(worker),
                    notice: "تم الحذف"
    end

    private

    def set_worker  = @worker  = current_user.workers.find_by(id: params[:worker_id])
    def set_advance = @advance = current_user.salary_advances.find(params[:id])

    def advance_params
      params.require(:salary_advance).permit(:amount, :currency, :advance_date, :reason, :settled)
    end
  end
end
