class OperationalMetric < ActiveRecord::Base
  validates_presence_of :task_id, :user_name, :completion
  validates_inclusion_of :completion, in: ['Break down', 'Break through'], message: "%{value} is not a valid completion status"
  
  # Allow team assignment
  # attr_accessible :team # Not needed in Rails 5+ with strong params, but good for clarity if using protected_attributes gem
end
