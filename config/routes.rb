Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  resources :buildings do
    resources :properties, only: [:new, :create, :index], shallow: true
  end

  resources :properties do
    member do
      patch :publish
      patch :mark_rented
      patch :mark_sold
    end
  end

  resources :cars do
    member do
      patch :publish
      patch :mark_rented
      patch :mark_sold
    end
  end

  namespace :dashboard do
    root "home#index"

    resource :agency, only: [:show, :edit, :update, :new, :create]

    resources :buildings do
      member do
        get  :manage_units
        post :bulk_create_units
      end
    end

    # ============================================================
    # WORKERS + nested sub-resources
    # ============================================================
    resources :workers do
      member do
        patch :toggle_active
        get   :payroll
        get   :attendance
      end

      resources :attendance_records, shallow: true,
                only: [:index, :new, :create, :edit, :update, :destroy]

      resources :worker_holidays, shallow: true,
                only: [:index, :new, :create, :edit, :update, :destroy]

      resources :salary_advances, shallow: true,
                only: [:index, :new, :create, :edit, :update, :destroy]

      resources :worker_payments, shallow: true,
                only: [:index, :new, :create, :edit, :update, :destroy]
    end

    # Top-level (flat) routes for shallow resources
    resources :attendance_records, only: [:index, :edit, :update, :destroy]
    resources :worker_holidays,    only: [:index, :edit, :update, :destroy]
    resources :salary_advances,    only: [:index, :edit, :update, :destroy]
    resources :worker_payments,    only: [:index, :edit, :update, :destroy]

    resources :payrolls, only: [:show]

    resources :tenants do
      member { patch :toggle_active }
    end

    resources :customers
    resources :cars, only: [:index]

    resources :contracts do
      member do
        get   :pdf
        patch :activate
        patch :complete
      end
    end

    resources :payments do
      member do
        patch :mark_paid
        get   :receipt
        get   :pdf
      end
    end

    resources :maintenances do
      member { patch :complete }
    end

    get "reports/properties", to: "reports#properties"
    get "reports/cars",       to: "reports#cars"
    get "reports/financials", to: "reports#financials"
  end

  get    "/billing/plans",                to: "billing/subscriptions#plans",   as: :billing_plans
  get    "/billing/subscription",         to: "billing/subscriptions#show",    as: :billing_subscription
  post   "/billing/subscription/upgrade", to: "billing/subscriptions#upgrade", as: :billing_upgrade_subscription

  namespace :billing do
    resources :payment_requests, only: [:index, :new, :create, :show]
  end

  namespace :admin do
    root "dashboard#index"

    resources :payment_requests, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end

    resources :agencies, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :approve
        patch :reject
        patch :suspend
      end
    end

    resources :properties, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :publish
        patch :unpublish
      end
    end

    resources :cars, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :publish
        patch :unpublish
      end
    end

    resources :users, only: [:index, :show] do
      member do
        patch :toggle_admin
        patch :toggle_verified
      end
    end

    resources :subscriptions, only: [:index, :show] do
      member do
        patch :activate
        patch :cancel
      end
    end

    resources :plans
    resource  :settings, only: [:show, :update]
  end

  get  "/search", to: "home#search", as: :home_search
  post "/search", to: "home#search"

  root "home#index"
end
