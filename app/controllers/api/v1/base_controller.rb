module Api
  module V1
    class BaseController < ApplicationController
      private

      def month_param
        Date.strptime(params[:month], "%Y-%m")
      rescue ArgumentError, TypeError
        Date.current.beginning_of_month
      end

      def render_unprocessable(model)
        render json: { errors: model.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
