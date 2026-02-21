class OperationalMetric < ActiveRecord::Base
  validates_presence_of :task_id, :user_name, :completion
  validates_inclusion_of :completion, in: ['Break down', 'Break through'], message: "%{value} is not a valid completion status"
  
  # Override spent_time= to handle decimal hours or H:MM input
  def spent_time=(value)
    if value.is_a?(String)
      if value.include?(':')
        hours, minutes = value.split(':').map(&:to_f)
        write_attribute(:spent_time, hours + (minutes / 60.0))
      else
        write_attribute(:spent_time, value.to_f)
      end
    else
      write_attribute(:spent_time, value)
    end
  end
end
