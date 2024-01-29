class Api::V1::TagsController < Api::V1::BaseController
  def index
    tags = current_user.tags
    json_string = TagSerializer.new(tags).serialize
    render json: json_string
  end
end
