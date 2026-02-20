class CreateHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :holidays do |t|
      t.date :holiday_date, null: false
    end
    add_index :holidays, :holiday_date, unique: true
  end
end
