module Api
  module V1
    class CategoriesController < BaseController
      before_action :set_category, only: [ :update, :destroy ]

      def index
        categories = Category.order(:kind, :sort_order, :id)
        render json: categories
      end

      def create
        category = Category.new(category_params)

        if category.save
          render json: category, status: :created
        else
          render_unprocessable(category)
        end
      end

      def update
        if @category.update(category_params)
          render json: @category
        else
          render_unprocessable(@category)
        end
      end

      def destroy
        if @category.destroy
          head :no_content
        else
          render_unprocessable(@category)
        end
      end

      private

      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :kind, :color, :sort_order)
      end
    end
  end
end
