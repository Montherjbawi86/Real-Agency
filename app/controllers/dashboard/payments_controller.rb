module Dashboard
  class PaymentsController < Dashboard::BaseController
    before_action :set_payment, only: [:edit, :update, :destroy, :mark_paid, :receipt, :pdf]

    def index
      @payments = current_user.payments.includes(:tenant, :customer, :contract).order(due_on: :desc)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @payments = @payments.joins("LEFT JOIN tenants   ON tenants.id   = payments.tenant_id")
                             .joins("LEFT JOIN customers ON customers.id = payments.customer_id")
                             .where("tenants.full_name ILIKE :q OR customers.full_name ILIKE :q OR CAST(payments.id AS TEXT) ILIKE :q", q: q)
      end

      @payments = @payments.where(status: params[:status]) if params[:status].present?
      @payments = @payments.where(currency: params[:currency]) if params[:currency].present?
      @payments = @payments.where(tenant_id: params[:tenant_id]) if params[:tenant_id].present?
      @payments = @payments.where(customer_id: params[:customer_id]) if params[:customer_id].present?

      @payments = case params[:sort]
      when "amount_high" then @payments.order(amount: :desc)
      when "due_soon"    then @payments.order(due_on: :asc)
      else                    @payments.order(due_on: :desc)
      end

      @counts = {
        all:     current_user.payments.count,
        paid:    current_user.payments.where(status: :paid).count,
        pending: current_user.payments.where(status: :pending).count,
        overdue: current_user.payments.overdue.count
      }
    end

    def new
      @payment = current_user.payments.new(currency: "SYP", due_on: Date.current)
      @payment.contract_id = params[:contract_id] if params[:contract_id].present?
    end

    def create
      @payment = current_user.payments.new(payment_params)
      if @payment.save
        redirect_to dashboard_payments_path, notice: "تم إضافة الدفعة ✅"
      else
        flash.now[:alert] = @payment.errors.full_messages.join(" — ")
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @payment.update(payment_params)
        redirect_to dashboard_payments_path, notice: "تم التحديث ✅"
      else
        flash.now[:alert] = @payment.errors.full_messages.join(" — ")
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @payment.destroy
      redirect_to dashboard_payments_path, notice: "تم الحذف"
    end

    def mark_paid
      @payment.update(status: :paid, paid_on: Date.current)
      redirect_to dashboard_payments_path, notice: "تم تحديد الدفعة كمدفوعة ✅"
    end

    def receipt
      render :receipt, layout: false
    end

    def pdf
      html = render_to_string(template: "dashboard/payments/pdf", layout: false, formats: [:html])
      pdf = WickedPdf.new.pdf_from_string(html, encoding: "UTF-8", page_size: "A4",
              margin: { top: 10, bottom: 10, left: 10, right: 10 }, print_media_type: true)
      send_data pdf, filename: "receipt-#{@payment.id}.pdf", type: "application/pdf", disposition: "inline"
    rescue => e
      redirect_to receipt_dashboard_payment_path(@payment), alert: "خطأ: #{e.message}"
    end

    private

    def set_payment = @payment = current_user.payments.find(params[:id])

    def payment_params
      params.require(:payment).permit(:contract_id, :tenant_id, :customer_id, :amount, :currency,
                                      :due_on, :paid_on, :payment_method, :status, :notes, :receipt)
    end
  end
end
