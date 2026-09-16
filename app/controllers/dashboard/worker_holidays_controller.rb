module Dashboard
  class WorkerHolidaysController < Dashboard::BaseController
    before_action :set_worker, only: [:index, :new, :create]
    before_action :set_holiday, only: [:destroy]

    def index
      if @worker
        @holidays = @worker.worker_holidays.recent
      else
        @holidays = current_user.worker_holidays.includes(:worker).recent
      end
    end

    def new
      @holiday = @worker.worker_holidays.new(
        user:          current_user,
        holiday_date:  Date.current,
        holiday_type:  :personal,
        paid:          true
      )
    end

    def create
      @holiday = current_user.worker_holidays.new(holiday_params)
      @holiday.worker = @worker
      if @holiday.save
        redirect_to dashboard_worker_worker_holidays_path(@worker),
                    notice: "✅ تم تسجيل الإجازة"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      worker = @holiday.worker
      @holiday.destroy
      redirect_back fallback_location: dashboard_worker_worker_holidays_path(worker),
                    notice: "تم الحذف"
    end

    private

    def set_worker   = @worker  = current_user.workers.find_by(id: params[:worker_id])
    def set_holiday  = @holiday = current_user.worker_holidays.find(params[:id])

    def holiday_params
      params.require(:worker_holiday).permit(:holiday_date, :holiday_type, :paid, :notes)
    end
  end
end
