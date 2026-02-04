class CreateTacticalMeetingsAndResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :tactical_meetings do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :facilitator
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' }
    end

    create_table :tactical_meeting_responses do |t|
      t.bigint :tactical_meeting_id, null: false
      t.integer :user_id, null: false
      t.text :individual_goal
      t.text :what_was_done
      t.text :what_not_done
      t.text :missing_from_my_end
      t.text :learnings
      t.text :results_commitment
      t.text :next_fortnight_goals
      t.text :problems_doubts_fears
      t.text :closure_notes
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' }
    end

    add_index :tactical_meeting_responses, [:tactical_meeting_id, :user_id], unique: true, name: 'uniq_meeting_user'
    add_foreign_key :tactical_meeting_responses, :tactical_meetings, column: :tactical_meeting_id, on_delete: :cascade
    add_foreign_key :tactical_meeting_responses, :users, column: :user_id, on_delete: :cascade
  end
end
