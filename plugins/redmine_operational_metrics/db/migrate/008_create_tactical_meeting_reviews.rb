class CreateTacticalMeetingReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :tactical_meeting_reviews do |t|
      t.bigint :tactical_meeting_response_id, null: false
      t.integer :reviewer_id, null: false
      t.string :role, null: false
      t.decimal :overall_score, precision: 5, scale: 2
      t.text :comment
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' }
    end

    add_index :tactical_meeting_reviews, :tactical_meeting_response_id, unique: true, name: 'uniq_review_per_response'
    add_foreign_key :tactical_meeting_reviews, :tactical_meeting_responses, on_delete: :cascade
    add_foreign_key :tactical_meeting_reviews, :users, column: :reviewer_id, on_delete: :cascade
  end
end
