module Api
  module V1
    class MonthlyBudgetsController < BaseController
      before_action :set_monthly_budget, only: [ :update, :destroy ]

      def index
        month = month_param.beginning_of_month
        budgets = MonthlyBudget.includes(:category).where(month: month).order("categories.sort_order ASC").references(:category)

        render json: budgets.map { |budget| budget_payload(budget) }
      end

      def create
        budget = MonthlyBudget.new(monthly_budget_params)
        budget.month = budget.month&.beginning_of_month

        if budget.save
          render json: budget_payload(budget), status: :created
        else
          render_unprocessable(budget)
        end
      end

      def update
        if @monthly_budget.update(monthly_budget_params)
          @monthly_budget.update!(month: @monthly_budget.month.beginning_of_month)
          render json: budget_payload(@monthly_budget)
        else
          render_unprocessable(@monthly_budget)
        end
      end

      def destroy
        @monthly_budget.destroy
        head :no_content
      end

      private

      def set_monthly_budget
        @monthly_budget = MonthlyBudget.find(params[:id])
      end

      def monthly_budget_params
        params.require(:monthly_budget).permit(:category_id, :month, :amount)
      end

      def budget_payload(budget)
        {
          id: budget.id,
          category_id: budget.category_id,
          category_name: budget.category.name,
          month: budget.month,
          amount: budget.amount.to_f
        }
      end
    end
  end
end
