class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :kind, null: false, default: "expense"
      t.string :color, null: false, default: "#64748b"
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end

    add_index :categories, [ :kind, :sort_order ]
    add_index :categories, [ :name, :kind ], unique: true
  end
end
