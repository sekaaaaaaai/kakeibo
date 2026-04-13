module Api
  module V1
    class ReportsController < BaseController
      def monthly
        month = month_param
        transactions_relation = Transaction
          .includes(:category)
          .in_month(month)
          .yield_self { |scope| filter_by_user(scope) }
        transactions = transactions_relation.to_a

        income = transactions.select { |t| t.category.kind_income? }.sum(&:amount)
        expense = transactions.select { |t| t.category.kind_expense? }.sum(&:amount)

        by_scope = %w[personal shared].map do |scope_name|
          scope_transactions = transactions.select { |t| t.aggregation_scope == scope_name }
          scope_income = scope_transactions.select { |t| t.category.kind_income? }.sum(&:amount)
          scope_expense = scope_transactions.select { |t| t.category.kind_expense? }.sum(&:amount)

          {
            scope: scope_name,
            income: scope_income.to_f,
            expense: scope_expense.to_f,
            balance: (scope_income - scope_expense).to_f
          }
        end

        by_category = transactions.group_by(&:category).map do |category, items|
          {
            category_id: category.id,
            category_name: category.name,
            kind: category.kind,
            total: items.sum(&:amount).to_f
          }
        end.sort_by { |item| [ item[:kind], -item[:total] ] }

        render json: {
          month: month.strftime("%Y-%m"),
          income: income.to_f,
          expense: expense.to_f,
          balance: (income - expense).to_f,
          by_scope: by_scope,
          by_category: by_category
        }
      end

      private

      def filter_by_user(scope)
        return scope if params[:user_id].blank?

        scope.where(user_id: params[:user_id])
      end
    end
  end
end
