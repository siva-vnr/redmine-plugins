class AddTeamToOperationalMetrics < ActiveRecord::Migration[5.2]
  def change
    add_column :operational_metrics, :team, :string
  end
end
