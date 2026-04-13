class RemoveAccountsFeature < ActiveRecord::Migration[8.1]
  def change
    if table_exists?(:transactions)
      remove_foreign_key :transactions, :accounts if foreign_key_exists?(:transactions, :accounts)
      remove_index :transactions, :account_id if index_exists?(:transactions, :account_id)
      remove_column :transactions, :account_id, :bigint if column_exists?(:transactions, :account_id)
    end

    drop_table :accounts, if_exists: true
  end
end
