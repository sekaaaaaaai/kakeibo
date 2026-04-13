module Api
  module V1
    class GroupsController < BaseController
      before_action :set_group, only: [ :update, :destroy ]

      def index
        render json: Group.order(:id)
      end

      def create
        group = Group.new(group_params)

        if group.save
          render json: group, status: :created
        else
          render_unprocessable(group)
        end
      end

      def update
        if @group.update(group_params)
          render json: @group
        else
          render_unprocessable(@group)
        end
      end

      def destroy
        if @group.destroy
          head :no_content
        else
          render_unprocessable(@group)
        end
      end

      private

      def set_group
        @group = Group.find(params[:id])
      end

      def group_params
        params.require(:group).permit(:name)
      end
    end
  end
end
