class AddGroupsUsersAndUserToTransactions < ActiveRecord::Migration[8.1]
  class MigrationGroup < ApplicationRecord
    self.table_name = "groups"
  end

  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  class MigrationTransaction < ApplicationRecord
    self.table_name = "transactions"
  end

  def up
    create_table :groups do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :groups, :name, unique: true

    create_table :users do |t|
      t.references :group, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :users, [ :group_id, :name ], unique: true

    add_reference :transactions, :user, foreign_key: true, null: true

    default_group = MigrationGroup.find_or_create_by!(name: "デフォルトグループ")
    default_user = MigrationUser.find_or_create_by!(group_id: default_group.id, name: "共通ユーザー")

    MigrationTransaction.where(user_id: nil).update_all(user_id: default_user.id)

    change_column_null :transactions, :user_id, false
    add_index :transactions, [ :user_id, :occurred_on ]
  end

  def down
    remove_index :transactions, [ :user_id, :occurred_on ] if index_exists?(:transactions, [ :user_id, :occurred_on ])
    remove_reference :transactions, :user, foreign_key: true

    drop_table :users
    drop_table :groups
  end
end
