class RenameRulesToScoringRules < ActiveRecord::Migration
  def up
    rename_table :rules, :scoring_rules
    rename_column :entities, :rule_id, :scoring_rule_id
  end

  def down
    rename_table :scoring_rules, :rules
    rename_column :entities, :scoring_rule_id, :rule_id
  end
end
