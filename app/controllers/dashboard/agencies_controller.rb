module Dashboard
  class AgenciesController < Dashboard::BaseController
    before_action :set_agency, only: [:show, :edit, :update]

    def show
      redirect_to new_dashboard_agency_path unless @agency
    end

    def new
      redirect_to dashboard_agency_path if current_user.agency
      @agency = current_user.build_agency
    end

    def create
      @agency = current_user.build_agency(agency_params)
      @agency.kind = current_user.property_agent? ? :property : :car
      if @agency.save
        redirect_to dashboard_agency_path, notice: "تم إنشاء الوكالة ✅"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @agency.update(agency_params)
        redirect_to dashboard_agency_path, notice: "تم تحديث الوكالة ✅"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_agency
      @agency = current_user.agency
    end

    def agency_params
      permitted = params.require(:agency).permit(
        :name, :city_id, :phone, :secondary_phone, :whatsapp, :email, :website, :address,
        :tax_number, :commercial_registry, :commercial_license,
        :professional_license, :company_registration,
        :founded_on, :authorized_person, :employees_count,
        :bank_name, :bank_account, :iban, :account_holder,
        :facebook_url, :instagram_url, :tiktok_url, :youtube_url, :twitter_url, :telegram_url,
        :description, :verified,
        :logo, :commercial_registry_file, :license_file, :tax_file
      )
      permitted.delete(:verified) unless current_user.admin?
      permitted
    end
  end
end
