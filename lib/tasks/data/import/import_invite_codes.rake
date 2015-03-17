namespace :data do
  desc "Imports funnel determinations from YAML file"
  task :import_invite_codes => :environment do

    Rails.logger.info "---"
    Rails.logger.info "Importing invite code definitions"

    definitions = YAML::load_file('config/invite_code_definitions.yml')
    existing    = InviteCode.pluck :code

    definitions.each do |d|
      code        = d['code']
      uses        = d['remaining_uses']
      valid_until = d['valid_until'] && Time.parse(d['valid_until'])

      if existing.include? code
        Rails.logger.info "Code #{code} already exists --> skipping!"
      else
        if InviteCode.new(code: code, remaining_uses: uses, valid_until: valid_until).save
          Rails.logger.info "Importing invite code '#{d['code']}' successful"
        else
          Rails.logger.info "Importing invite code '#{d['code']}' failed"
        end
      end
    end

  end
end
