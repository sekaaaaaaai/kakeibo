module Api
  module V1
    class TransactionsController < BaseController
      before_action :set_transaction, only: [ :update, :destroy ]

      def index
        month = month_param
        transactions = Transaction
          .includes(:category, :user)
          .in_month(month)
          .yield_self { |scope| filter_by_user(scope) }
          .order(occurred_on: :desc, id: :desc)

        render json: transactions.map { |transaction| transaction_payload(transaction) }
      end

      def create
        transaction = Transaction.new(transaction_params)

        if transaction.save
          render json: transaction_payload(transaction), status: :created
        else
          render_unprocessable(transaction)
        end
      end

      def update
        if @transaction.update(transaction_params)
          render json: transaction_payload(@transaction)
        else
          render_unprocessable(@transaction)
        end
      end

      def destroy
        @transaction.destroy
        head :no_content
      end

      private

      def set_transaction
        @transaction = Transaction.find(params[:id])
      end

      def transaction_params
        params.require(:transaction).permit(:user_id, :category_id, :amount, :occurred_on, :memo, :aggregation_scope)
      end

      def filter_by_user(scope)
        return scope if params[:user_id].blank?

        scope.where(user_id: params[:user_id])
      end

      def transaction_payload(transaction)
        {
          id: transaction.id,
          user_id: transaction.user_id,
          user_name: transaction.user.name,
          category_id: transaction.category_id,
          category_name: transaction.category.name,
          category_kind: transaction.category.kind,
          aggregation_scope: transaction.aggregation_scope,
          amount: transaction.amount.to_f,
          occurred_on: transaction.occurred_on,
          memo: transaction.memo
        }
      end
    end
  end
end
