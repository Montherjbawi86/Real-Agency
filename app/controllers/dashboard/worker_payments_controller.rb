module Dashboard
  class WorkerPaymentsController < Dashboard::BaseController
    before_action :set_worker,  only: [:index, :new, :create]
    before_action :set_payment, only: [:show, :destroy]

    def index
      if @worker
        @payments   = @worker.worker_payments.recent
        @total_paid = @worker.total_paid
        @remaining  = @worker.remaining_for_month
      else
        @payments   = current_user.worker_payments.includes(:worker).recent
        @total_paid = current_user.worker_payments.sum(:amount) || 0
      end
    end

    def new
      unless @worker
        redirect_to dashboard_workers_path, alert: "اختر عاملًا أولاً"
        return
      end
      @payment = @worker.worker_payments.new(
        user:         current_user,
        amount:       @worker.salary,
        currency:     @worker.currency,
        paid_on:      Date.current,
        for_month:    Date.current.beginning_of_month
      )
    end

    def create
      unless @worker
        redirect_to dashboard_workers_path, alert: "اختر عاملًا أولاً"
        return
      end
      @payment = current_user.worker_payments.new(payment_params)
      @payment.worker = @worker

      if @payment.save
        redirect_to dashboard_worker_worker_payments_path(@worker),
                    notice: "✅ تم تسجيل الدفعة"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      redirect_to dashboard_worker_worker_payments_path(@payment.worker)
    end

    def destroy
      worker = @payment.worker
      @payment.destroy
      redirect_to dashboard_worker_worker_payments_path(worker),
                  notice: "تم حذف الدفعة"
    end

    private

    def set_worker  = @worker  = current_user.workers.find_by(id: params[:worker_id])
    def set_payment = @payment = current_user.worker_payments.find(params[:id])

    def payment_params
      params.require(:worker_payment).permit(
        :amount, :currency, :paid_on, :for_month, :payment_method, :notes
      )
    end
  end
end
