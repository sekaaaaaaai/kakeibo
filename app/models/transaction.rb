class Transaction < ApplicationRecord
  enum :aggregation_scope, { personal: "personal", shared: "shared" }, prefix: true

  belongs_to :user
  belongs_to :category

  validates :amount, numericality: { greater_than: 0 }
  validates :occurred_on, presence: true
  validates :aggregation_scope, inclusion: { in: aggregation_scopes.keys }

  scope :in_month, lambda { |month_date|
    range = month_date.beginning_of_month..month_date.end_of_month
    where(occurred_on: range)
  }

  def signed_amount
    category.kind_income? ? amount : -amount
  end
end
