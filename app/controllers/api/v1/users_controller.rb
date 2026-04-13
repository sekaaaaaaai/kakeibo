module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [ :update, :destroy ]

      def index
        users = User.includes(:group).order(:group_id, :id)
        render json: users.map { |user| user_payload(user) }
      end

      def create
        user = User.new(user_params)

        if user.save
          render json: user_payload(user), status: :created
        else
          render_unprocessable(user)
        end
      end

      def update
        if @user.update(user_params)
          render json: user_payload(@user)
        else
          render_unprocessable(@user)
        end
      end

      def destroy
        if @user.destroy
          head :no_content
        else
          render_unprocessable(@user)
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:name, :group_id)
      end

      def user_payload(user)
        {
          id: user.id,
          name: user.name,
          group_id: user.group_id,
          group_name: user.group.name
        }
      end
    end
  end
end
