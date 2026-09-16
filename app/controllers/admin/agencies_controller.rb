module Admin
  class AgenciesController < Admin::BaseController
    before_action :set_agency, only: [:show, :edit, :update, :destroy, :approve, :reject, :suspend]

    def index
      @agencies = Agency.includes(:user, :city).order(created_at: :desc)
      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @agencies = @agencies.where("name ILIKE :q OR phone ILIKE :q OR tax_number ILIKE :q", q: q)
      end
      @agencies = @agencies.where(approval_status: params[:status]) if params[:status].present?
      @counts = {
        all:       Agency.count,
        pending:   Agency.where(approval_status: :pending).count,
        approved:  Agency.where(approval_status: :approved).count,
        rejected:  Agency.where(approval_status: :rejected).count,
        suspended: Agency.where(approval_status: :suspended).count
      }
    end

    def show
      @properties = @agency.user.properties.limit(10) if @agency.property?
      @cars       = @agency.user.cars.limit(10) if @agency.car?
    end

    def edit; end

    def update
      if @agency.update(agency_params)
        redirect_to admin_agency_path(@agency), notice: "✅ تم تحديث الوكالة"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @agency.destroy
      redirect_to admin_agencies_path, notice: "تم حذف الوكالة"
    end

    def approve
      @agency.approve!(current_user)
      redirect_to admin_agency_path(@agency), notice: "✅ تمت الموافقة على الوكالة"
    end

    def reject
      @agency.reject!(current_user, reason: params[:reason])
      redirect_to admin_agency_path(@agency), notice: "❌ تم رفض الوكالة"
    end

    def suspend
      @agency.suspend!(current_user, reason: params[:reason])
      redirect_to admin_agency_path(@agency), notice: "⏸️ تم إيقاف الوكالة"
    end

    private

    def set_agency = @agency = Agency.find(params[:id])

    def agency_params
      params.require(:agency).permit(
        :name, :kind, :phone, :secondary_phone, :whatsapp, :email, :website, :address,
        :city_id, :description, :tax_number, :commercial_registry, :commercial_license,
        :professional_license, :company_registration, :founded_on, :authorized_person,
        :employees_count, :bank_name, :bank_account, :iban, :account_holder,
        :verified, :approval_status, :logo
      )
    end
  end
end
