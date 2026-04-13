class Category < ApplicationRecord
  enum :kind, { expense: "expense", income: "income" }, prefix: true

  has_many :transactions, dependent: :destroy
  has_many :monthly_budgets, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :kind }
  validates :color, presence: true
  validates :sort_order, numericality: { only_integer: true }
end
