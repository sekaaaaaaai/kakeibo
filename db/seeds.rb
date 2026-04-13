puts "Seeding kakeibo data..."

default_group = Group.find_or_create_by!(name: "家計")
alice = User.find_or_create_by!(group: default_group, name: "Alice")
bob = User.find_or_create_by!(group: default_group, name: "Bob")

expense_categories = [
  [ "食費", "#ef4444", 10 ],
  [ "日用品", "#f97316", 20 ],
  [ "交通", "#06b6d4", 30 ],
  [ "固定費", "#6366f1", 40 ]
]

income_categories = [
  [ "給与", "#16a34a", 10 ],
  [ "副収入", "#22c55e", 20 ]
]

expense_categories.each do |name, color, sort_order|
  Category.find_or_create_by!(name: name, kind: "expense") do |category|
    category.color = color
    category.sort_order = sort_order
  end
end

income_categories.each do |name, color, sort_order|
  Category.find_or_create_by!(name: name, kind: "income") do |category|
    category.color = color
    category.sort_order = sort_order
  end
end

current_month = Date.current.beginning_of_month
food = Category.find_by!(name: "食費", kind: "expense")
rent = Category.find_by!(name: "固定費", kind: "expense")

MonthlyBudget.find_or_create_by!(category: food, month: current_month) do |budget|
  budget.amount = 40_000
end

MonthlyBudget.find_or_create_by!(category: rent, month: current_month) do |budget|
  budget.amount = 70_000
end

if Transaction.count == 0
  Transaction.create!(user: alice, category: Category.find_by!(name: "給与", kind: "income"), aggregation_scope: "shared", amount: 300_000, occurred_on: current_month + 1.day, memo: "給料")
  Transaction.create!(user: alice, category: food, aggregation_scope: "personal", amount: 3_200, occurred_on: current_month + 2.days, memo: "スーパー")
  Transaction.create!(user: bob, category: Category.find_by!(name: "交通", kind: "expense"), aggregation_scope: "shared", amount: 1_200, occurred_on: current_month + 3.days, memo: "電車")
end

puts "Seed complete: groups=#{Group.count}, users=#{User.count}, categories=#{Category.count}, transactions=#{Transaction.count}, monthly_budgets=#{MonthlyBudget.count}"
