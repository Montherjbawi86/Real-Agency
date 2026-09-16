module Dashboard
  class ReportsController < Dashboard::BaseController
    def properties
      @properties      = current_user.properties
      @total_count     = @properties.count
      @published_count = @properties.published.count
      @rented_count    = @properties.rented.count
      @sold_count      = @properties.sold.count
      @draft_count     = @properties.draft.count

      @sale_count      = @properties.sale.count
      @rent_count      = @properties.rent.count

      @by_status       = @properties.group(:status).count
      @by_type         = @properties.group(:property_type).count
      @by_city         = @properties.group(:city_id).count

      @total_value_syp = @properties.where(currency: "SYP").sum(:price) || 0
      @total_value_usd = @properties.where(currency: "USD").sum(:price) || 0

      @avg_price_syp   = @properties.where(currency: "SYP").average(:price).to_f || 0
      @avg_size        = @properties.average(:size).to_f || 0
      @avg_rooms       = @properties.average(:rooms).to_f || 0

      @total_contract_syp  = current_user.contracts.for_properties.where(currency: "SYP").sum(:amount) || 0
      @total_contract_usd  = current_user.contracts.for_properties.where(currency: "USD").sum(:amount) || 0
      @total_paid_syp      = current_user.payments.joins(:contract).where(contracts: { property_id: current_user.property_ids }, status: :paid, currency: "SYP").sum(:amount) || 0
      @total_paid_usd      = current_user.payments.joins(:contract).where(contracts: { property_id: current_user.property_ids }, status: :paid, currency: "USD").sum(:amount) || 0
      @total_remaining_syp = @total_contract_syp - @total_paid_syp
      @total_remaining_usd = @total_contract_usd - @total_paid_usd

      # Buildings
      @buildings               = current_user.buildings.includes(:properties).order(:name)
      @total_buildings         = @buildings.count
      @total_units_in_buildings = @properties.where.not(building_id: nil).count
      @standalone_properties   = @properties.where(building_id: nil).count
      @by_building             = @buildings.map { |b| [b.name, b.total_units] }.to_h

      @recent     = @properties.recent.limit(10)
      @city_names = City.where(id: @by_city.keys).pluck(:id, :name_ar).to_h
    end

    def cars
      @cars            = current_user.cars
      @total_count     = @cars.count
      @published_count = @cars.published.count
      @rented_count    = @cars.rented.count
      @sold_count      = @cars.sold.count
      @draft_count     = @cars.draft.count

      @by_status       = @cars.group(:status).count
      @by_brand        = @cars.group(:brand).count

      @total_value_syp = @cars.where(currency: "SYP").sum(:price) || 0
      @total_value_usd = @cars.where(currency: "USD").sum(:price) || 0

      @avg_mileage     = @cars.average(:mileage).to_f || 0

      @total_contract_syp  = current_user.contracts.for_cars.where(currency: "SYP").sum(:amount) || 0
      @total_contract_usd  = current_user.contracts.for_cars.where(currency: "USD").sum(:amount) || 0
      @total_paid_syp      = current_user.payments.joins(:contract).where(contracts: { car_id: current_user.car_ids }, status: :paid, currency: "SYP").sum(:amount) || 0
      @total_paid_usd      = current_user.payments.joins(:contract).where(contracts: { car_id: current_user.car_ids }, status: :paid, currency: "USD").sum(:amount) || 0
      @total_remaining_syp = @total_contract_syp - @total_paid_syp
      @total_remaining_usd = @total_contract_usd - @total_paid_usd

      @recent = @cars.recent.limit(10)
    end

    def financials
      payments = current_user.payments

      @paid_payments     = payments.paid
      @paid_count        = @paid_payments.count
      @paid_total_syp    = @paid_payments.where(currency: "SYP").sum(:amount) || 0
      @paid_total_usd    = @paid_payments.where(currency: "USD").sum(:amount) || 0

      @pending_payments  = payments.pending
      @pending_count     = @pending_payments.count
      @pending_total_syp = @pending_payments.where(currency: "SYP").sum(:amount) || 0
      @pending_total_usd = @pending_payments.where(currency: "USD").sum(:amount) || 0

      @overdue_payments  = payments.overdue
      @overdue_count     = @overdue_payments.count
      @overdue_total_syp = @overdue_payments.where(currency: "SYP").sum(:amount) || 0
      @overdue_total_usd = @overdue_payments.where(currency: "USD").sum(:amount) || 0

      @total_contract_syp  = current_user.contracts.where(currency: "SYP").sum(:amount) || 0
      @total_contract_usd  = current_user.contracts.where(currency: "USD").sum(:amount) || 0
      @total_remaining_syp = @total_contract_syp - @paid_total_syp
      @total_remaining_usd = @total_contract_usd - @paid_total_usd

      this_month = Date.current.beginning_of_month..Date.current.end_of_month
      @this_month_paid      = @paid_payments.where(paid_on: this_month)
      @this_month_total_syp = @this_month_paid.where(currency: "SYP").sum(:amount) || 0
      @this_month_total_usd = @this_month_paid.where(currency: "USD").sum(:amount) || 0

      @maintenance_cost_syp = current_user.maintenances.where(currency: "SYP").sum(:cost) || 0
      @maintenance_cost_usd = current_user.maintenances.where(currency: "USD").sum(:cost) || 0
      @maintenance_count    = current_user.maintenances.count

      @workers_active = current_user.workers.active
      @workers_count  = @workers_active.count
      @salaries_syp   = @workers_active.where(currency: "SYP").sum(:salary) || 0
      @salaries_usd   = @workers_active.where(currency: "USD").sum(:salary) || 0

      @recent_paid = @paid_payments.order(paid_on: :desc).limit(10)

      @top_tenants = current_user.payments.paid
        .joins("LEFT JOIN tenants   ON tenants.id   = payments.tenant_id")
        .joins("LEFT JOIN customers ON customers.id = payments.customer_id")
        .where(currency: "SYP")
        .group("COALESCE(tenants.full_name, customers.full_name)")
        .order("SUM(payments.amount) DESC")
        .limit(5)
        .sum(:amount)
        .to_a
    end
  end
end
