class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.date :occurred_on, null: false
      t.string :memo

      t.timestamps
    end

    add_index :transactions, :occurred_on
  end
end
