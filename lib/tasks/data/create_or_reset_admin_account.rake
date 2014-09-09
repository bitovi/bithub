namespace :data do
  desc "Creates or resets Account with :admin role"
  task :create_or_reset_admin_account => :environment do

	DEFAULT_USERNAME = 'admin@bithub.com'

    STDOUT.puts "Email/Username [#{DEFAULT_USERNAME}]:"
    username = STDIN.gets.chomp
	username = DEFAULT_USERNAME if username.empty?

    if admin = Account.where(email: username).first
      puts "Username '#{username}' already exists! Adding 'admin' role..."
      admin.add_role :admin

      puts "New password (leave empty to skip):"
      password = STDIN.gets.chomp

      unless password.empty?
        admin.password = password
        if admin.save
          puts "Password reseted!"
        else
          puts "Updating failed!"
        end
      end

    else
      puts "New password:"
      password = STDIN.gets.chomp

      admin = Account.new({email: username, password: password})
      admin.add_role :admin

      if admin.save
        puts "New admin account created!"
      else
        puts "Creating new admin account failed!"
      end
    end

  end
end
