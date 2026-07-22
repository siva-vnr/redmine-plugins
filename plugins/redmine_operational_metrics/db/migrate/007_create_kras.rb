class CreateKras < ActiveRecord::Migration[5.2]
  def change
    create_table :kras do |t|
      t.string :role, null: false
      t.string :name, null: false
      t.decimal :weight, precision: 5, scale: 2, null: false
      t.integer :position, null: false, default: 0
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' }
    end

    add_index :kras, [:role, :name], unique: true, name: 'uniq_role_kra_name'
  end
end
