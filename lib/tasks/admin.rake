namespace :admin do
  desc "Create or update admin user from ENV"
  task create: :environment do
    return unless ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?

    email = ENV["ADMIN_EMAIL"]
    user  = User.find_or_initialize_by(email: email)

    if user.new_record?
      user.password = ENV["ADMIN_PASSWORD"]
      user.password_confirmation = ENV["ADMIN_PASSWORD"]
    end

    user.full_name = ENV.fetch("ADMIN_NAME", "Admin")        if user.respond_to?(:full_name=)
    user.phone     = ENV.fetch("ADMIN_PHONE", "0991234567")   if user.respond_to?(:phone=)
    user.admin     = true                                     if user.respond_to?(:admin=)
    user.role      = ENV.fetch("ADMIN_ROLE", "property_agent") if user.respond_to?(:role=)

    if user.save
      puts "✅ Admin ready: #{user.email} (role: #{user.role}, admin: #{user.admin})"
    else
      puts "❌ Failed: #{user.errors.full_messages.join(', ')}"
      exit 1
    end
  end
end
