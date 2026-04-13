class AddAggregationScopeToTransactions < ActiveRecord::Migration[8.1]
  def up
    add_column :transactions, :aggregation_scope, :string

    execute <<~SQL.squish
      UPDATE transactions
      SET aggregation_scope = 'shared'
      WHERE aggregation_scope IS NULL
    SQL

    change_column_null :transactions, :aggregation_scope, false
    add_index :transactions, :aggregation_scope
  end

  def down
    remove_index :transactions, :aggregation_scope if index_exists?(:transactions, :aggregation_scope)
    remove_column :transactions, :aggregation_scope
  end
end
