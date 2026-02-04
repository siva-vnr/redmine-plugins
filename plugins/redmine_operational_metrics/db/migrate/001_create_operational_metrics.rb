class CreateOperationalMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :operational_metrics do |t|
      t.integer :task_id, null: false
      t.string :user_name, null: false
      t.string :project
      t.text :task_planed
      t.date :task_date
      t.integer :spent_time
      t.text :spent_detail
      t.string :collaborate_with
      t.string :completion, null: false
      t.timestamp :updated_at
    end
  end
end
