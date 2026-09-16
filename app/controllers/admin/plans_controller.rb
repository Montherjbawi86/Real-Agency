module Admin
  class PlansController < Admin::BaseController
    before_action :set_plan, only: [:show, :edit, :update, :destroy]

    def index
      @plans = Plan.order(:position, :price_syp)
    end

    def show; end

    def new
      @plan = Plan.new(active: true)
    end

    def create
      @plan = Plan.new(plan_params)
      if @plan.save
        redirect_to admin_plans_path, notice: "✅ تم إنشاء الخطة"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @plan.update(plan_params)
        redirect_to admin_plans_path, notice: "✅ تم تحديث الخطة"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @plan.destroy
      redirect_to admin_plans_path, notice: "تم حذف الخطة"
    end

    private

    def set_plan = @plan = Plan.find(params[:id])

    def plan_params
      params.require(:plan).permit(:name, :name_ar, :slug, :price_syp, :price_usd,
                                   :max_listings, :duration_days, :features, :active, :position)
    end
  end
end
