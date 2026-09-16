module Dashboard
  class PayrollsController < Dashboard::BaseController
    def show
      @worker = current_user.workers.find(params[:id])
      @month  = params[:month].present? ? Date.parse(params[:month]) : Date.current

      @calculated  = @worker.calculated_salary_for(@month)
      @overtime    = @worker.overtime_pay(@month)
      @advances    = @worker.advances_total(@month)
      @net_salary  = @worker.net_salary_for(@month)
      @paid        = @worker.paid_for_month(@month)
      @remaining   = @worker.remaining_for_month(@month)

      @days_present  = @worker.days_present(@month)
      @days_absent   = @worker.days_absent(@month)
      @hours_worked  = @worker.hours_worked(@month)
      @overtime_hours = @worker.overtime_hours(@month)
      @holidays      = @worker.worker_holidays.in_month(@month)
      @advances_list = @worker.salary_advances.in_month(@month)
      @payments      = @worker.worker_payments.where(for_month: @month.beginning_of_month..@month.end_of_month).recent
    end
  end
end
