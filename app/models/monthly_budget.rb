class MonthlyBudget < ApplicationRecord
  belongs_to :category

  validates :month, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :category_id, uniqueness: { scope: :month }
  validate :month_is_first_day

  private

  def month_is_first_day
    return if month.blank? || month.day == 1

    errors.add(:month, "must be the first day of month")
  end
end
