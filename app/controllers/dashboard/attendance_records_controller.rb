module Dashboard
  class AttendanceRecordsController < Dashboard::BaseController
    before_action :set_worker, only: [:index, :new, :create]
    before_action :set_record, only: [:edit, :update, :destroy]

    def index
      @month = parse_month(params[:month])

      if @worker
        # Worker-specific view
        @records = @worker.attendance_records.in_month(@month).recent
        @summary = {
          present:  @worker.days_present(@month),
          absent:   @worker.days_absent(@month),
          hours:    @worker.hours_worked(@month),
          overtime: @worker.overtime_hours(@month)
        }
      else
        # Global view across all workers
        @records = current_user.attendance_records
                      .in_month(@month)
                      .includes(:worker)
                      .recent

        # Filters
        if params[:q].present?
          q = "%#{params[:q].strip}%"
          @records = @records.joins(:worker)
                             .where("workers.full_name ILIKE :q OR workers.phone ILIKE :q OR attendance_records.notes ILIKE :q", q: q)
        end

        @records = @records.where(status: params[:status]) if params[:status].present?
        @records = @records.where(worker_id: params[:worker_id]) if params[:worker_id].present?

        # Sort
        @records = case params[:sort]
        when "oldest"   then @records.reorder(work_date: :asc)
        when "hours"    then @records.reorder(total_hours: :desc)
        when "overtime" then @records.reorder(overtime_hours: :desc)
        else                 @records
        end

        # Summary
        base = current_user.attendance_records.in_month(@month)
        @month_totals = {
          present:  base.present.count,
          absent:   base.absent.count,
          hours:    base.sum(:total_hours) || 0,
          overtime: base.sum(:overtime_hours) || 0
        }

        # Per-worker summary for the current month
        @worker_summaries = current_user.workers.active.map do |w|
          {
            worker:   w,
            present:  w.days_present(@month),
            absent:   w.days_absent(@month),
            hours:    w.hours_worked(@month),
            overtime: w.overtime_hours(@month)
          }
        end.sort_by { |s| -s[:present] }

        @workers = current_user.workers.order(:full_name)
        @counts = {
          all:      base.count,
          present:  base.present.count,
          absent:   base.absent.count,
          late:     base.late.count,
          leave:    base.leave.count
        }
      end
    end

    def new
      unless @worker
        redirect_to dashboard_workers_path, alert: "اختر عاملًا أولاً"
        return
      end
      @record = @worker.attendance_records.new(
        user: current_user, work_date: Date.current, status: :present,
        check_in: "08:00", check_out: "16:00"
      )
    end

    def create
      unless @worker
        redirect_to dashboard_workers_path, alert: "اختر عاملًا أولاً"
        return
      end
      @record = current_user.attendance_records.new(record_params)
      @record.worker = @worker
      if @record.save
        redirect_to dashboard_worker_attendance_records_path(@worker),
                    notice: "✅ تم تسجيل الحضور"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @record.update(record_params)
        redirect_to dashboard_worker_attendance_records_path(@record.worker),
                    notice: "✅ تم التحديث"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      worker = @record.worker
      @record.destroy
      redirect_back fallback_location: dashboard_worker_attendance_records_path(worker),
                    notice: "تم الحذف"
    end

    private

    def parse_month(param)
      return Date.current unless param.present?
      Date.parse(param)
    rescue ArgumentError
      Date.current
    end

    def set_worker = @worker  = current_user.workers.find_by(id: params[:worker_id])
    def set_record = @record  = current_user.attendance_records.find(params[:id])

    def record_params
      params.require(:attendance_record).permit(:work_date, :check_in, :check_out, :status, :notes)
    end
  end
end
