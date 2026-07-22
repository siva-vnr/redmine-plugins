class CreateTacticalMeetingReviewItems < ActiveRecord::Migration[5.2]
  def change
    create_table :tactical_meeting_review_items do |t|
      t.bigint :tactical_meeting_review_id, null: false
      t.bigint :kra_id
      t.string :kra_name, null: false
      t.decimal :weight, precision: 5, scale: 2, null: false
      t.decimal :score, precision: 5, scale: 2, null: false
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' }
    end

    add_foreign_key :tactical_meeting_review_items, :tactical_meeting_reviews, on_delete: :cascade
    add_foreign_key :tactical_meeting_review_items, :kras, on_delete: :nullify
  end
end
