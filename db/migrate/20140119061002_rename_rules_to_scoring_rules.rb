class RenameRulesToScoringRules < ActiveRecord::Migration
  def up
    rename_table 'rules', 'scoring_rules'
  end

  def down
    rename_table 'scoring_rules', 'rules'
  end
end
