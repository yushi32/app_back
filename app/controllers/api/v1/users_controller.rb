class Api::V1::UsersController < Api::V1::BaseController
  include LineApiClient

  def show
    json_string = UserSerializer.new(current_user).serialize
    render json: json_string
  end

  def update
    if current_user.update(user_params)
      head :no_content
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # リクエストヘッダーにLINEのIDトークンが含まれる場合は、line_user_idの更新処理を行う
  def user_params
    if request.headers['X-LINE-AccessToken']
      line_user_id = get_line_user_id(request.headers['X-LINE-AccessToken'])
      { line_user_id: line_user_id }
    else
      # 現時点でどのカラムの更新も想定していないので、誤ってトリガーされてもパラメータを受け取らないようにする
      params.require(:user).permit()
    end
  end
end
