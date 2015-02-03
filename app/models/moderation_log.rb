class ModerationLog < ActiveRecord::Base
  singleton_class.send(:alias_method, :new_entry, :create)
end
