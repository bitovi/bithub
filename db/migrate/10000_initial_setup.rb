class InitialSetup < ActiveRecord::Migration
  def change
    unless ENV['VAGRANT'].present?
      create_extension "hstore", :version => "1.2"
      create_extension "intarray", :version => "1.0"
      create_extension "btree_gin"
    end

    enable_extension "plpgsql"
    enable_extension "hstore"
    enable_extension "intarray"
  end
end
