namespace :data do
  desc "Imports/updates tags from YAML file"
  task :import_or_update_tags => :environment do

    Rails.logger.info "---"
    Rails.logger.info "Importing/updating tags"

    if tenant = ENV['TENANT']
      Apartment::Tenant.switch! tenant
      Rails.logger.info "Tenant switched to '#{Apartment::Tenant.current}'"
    end

    tags = YAML::load_file('config/tag_definitions.yml')
    updated = []
    imported = []
    failed = []

    tags.each do |tag_name, opts|
      attrs = {
        display_name: opts['display_name'],
        aliases: opts['aliases'],
        props: opts['props']
      }

      if existing = Tag.find_by_name(tag_name)
        existing.assign_attributes(attrs)
        existing.add_groups(opts['group_list']) if opts['group_list']
        existing.save ? updated.push(tag_name) : failed.push(tag_name)
      else
        t = Tag.new({:name => tag_name}.merge(attrs))
        t.group_list = opts['group_list']
        t.save ? imported.push(tag_name) : failed.push(tag_name)
      end
    end

    Rails.logger.info "Summary:"
    Rails.logger.info "  #{imported.length} tags imported"
    Rails.logger.info "  #{updated.length} tags updated"
    Rails.logger.info "  #{failed.length} tags failed: #{failed.to_s}"

    Apartment::Tenant.switch!
  end
end
