class Kra < ActiveRecord::Base
  ROLES = ['Solution Architect', 'Project Engineer'].freeze

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :name, presence: true, uniqueness: { scope: :role }
  validates :weight, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
end
