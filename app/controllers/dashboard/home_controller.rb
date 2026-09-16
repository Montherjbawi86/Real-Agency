module Dashboard
  class HomeController < Dashboard::BaseController
    def index
      if current_user.property_agent?
        load_property_stats
      else
        load_car_stats
      end
    end

    private

    def load_property_stats
      @properties       = current_user.properties
      @properties_count = @properties.count
      @published_count  = @properties.published.count
      @rented_count     = @properties.rented.count
      @sold_count       = @properties.sold.count
      @draft_count      = @properties.draft.count

      @buildings        = current_user.buildings
      @buildings_count  = @buildings.count
      @total_units      = @properties.where.not(building_id: nil).count

      @tenants          = current_user.tenants.active
      @unpaid_payments  = current_user.payments.unpaid
      @overdue_payments = current_user.payments.overdue
      @maintenances     = current_user.maintenances.where(maintainable_type: "Property")
    end

    def load_car_stats
      @cars             = current_user.cars
      @cars_count       = @cars.count
      @published_count  = @cars.published.count
      @rented_count     = @cars.rented.count
      @sold_count       = @cars.sold.count
      @draft_count      = @cars.draft.count
      @customers        = current_user.customers.recent.limit(5)
      @customers_count  = current_user.customers.count
      @active_contracts = current_user.contracts.for_cars.active.count
      @unpaid_payments  = current_user.payments.unpaid
      @overdue_payments = current_user.payments.overdue
      @recent_payments  = current_user.payments.recent.limit(5)
      @maintenances     = current_user.maintenances.where(maintainable_type: "Car")
    end
  end
end
