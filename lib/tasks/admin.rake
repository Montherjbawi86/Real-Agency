namespace :admin do
  desc "Create or update an admin user (uses ADMIN_EMAIL, ADMIN_PASSWORD, ADMIN_NAME, ADMIN_PHONE, ADMIN_ROLE)"
  task create: :environment do
    email    = ENV.fetch("ADMIN_EMAIL")    { abort "ADMIN_EMAIL is required" }
    password = ENV.fetch("ADMIN_PASSWORD") { abort "ADMIN_PASSWORD is required" }
    name     = ENV.fetch("ADMIN_NAME", "Admin")
    phone    = ENV.fetch("ADMIN_PHONE", "0991234567")
    role     = ENV.fetch("ADMIN_ROLE", "property_agent")

    user = User.find_or_initialize_by(email: email)

    if user.new_record?
      user.password = password
      user.password_confirmation = password
    end

    user.full_name = name if user.respond_to?(:full_name=)
    user.phone     = phone if user.respond_to?(:phone=)
    user.admin     = true  if user.respond_to?(:admin=)
    user.role      = role  if user.respond_to?(:role=)

    if user.save
      puts "Admin user ready: #{user.email} (role: #{user.role}, admin: #{user.admin})"
    else
      puts "Failed: #{user.errors.full_messages.join(', ')}"
      exit 1
    end
  end
end
