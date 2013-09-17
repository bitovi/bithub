class ActorCanBeNullInInternals < ActiveRecord::Migration
  def up
    change_table :internals do |t|
      t.change :actor_id, :integer, :null => true
    end
  end

  def down
    change_table :internals do |t|
      t.change :actor_id, :integer, :null => false
    end
  end
end
