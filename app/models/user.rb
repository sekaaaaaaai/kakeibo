class User < ApplicationRecord
  belongs_to :group
  has_many :transactions, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :group_id }
end
