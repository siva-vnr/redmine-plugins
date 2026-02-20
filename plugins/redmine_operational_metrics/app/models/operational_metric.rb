class OperationalMetric < ActiveRecord::Base
  validates_presence_of :task_id, :user_name, :completion
  validates_inclusion_of :completion, in: ['Break down', 'Break through'], message: "%{value} is not a valid completion status"
  
  # Override spent_time= to handle HH.MM input
  def spent_time=(value)
    if value.is_a?(String) && value.include?('.')
      hours, minutes = value.split('.').map(&:to_i)
      total_minutes = (hours * 60) + (minutes || 0)
      write_attribute(:spent_time, total_minutes)
    else
      write_attribute(:spent_time, value)
    end
  end

  # Helper to format integer minutes back to HH:MM or HH.MM
  def formatted_spent_time
    return "0.00" if spent_time.blank?
    hours = spent_time / 60
    minutes = spent_time % 60
    "#{hours}.#{minutes.to_s.rjust(2, '0')}"
  end
end
