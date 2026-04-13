class CreateMonthlyBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :monthly_budgets do |t|
      t.references :category, null: false, foreign_key: true
      t.date :month, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false

      t.timestamps
    end

    add_index :monthly_budgets, [ :category_id, :month ], unique: true
  end
end
