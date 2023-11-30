class Api::V1::FoldersController < Api::V1::BaseController
  def index
    folders = current_user.root_folders.order(created_at: :asc)
    json_string = FolderSerializer.new(folders, within: { children: :folders }).serialize
    render json: json_string
  end

  def create
  end

  def update
  end

  def destroy
  end
end
