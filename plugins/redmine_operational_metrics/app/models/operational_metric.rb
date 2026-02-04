class OperationalMetric < ActiveRecord::Base
  validates_presence_of :task_id, :user_name, :completion
  validates_inclusion_of :completion, in: ['Break down', 'Break through'], message: "%{value} is not a valid completion status"
end
