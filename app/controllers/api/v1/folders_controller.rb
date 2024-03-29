class Api::V1::FoldersController < Api::V1::BaseController
  def index
    folders = current_user.folders.includes(:children).order(position: :asc)
    json_string = FolderSerializer.new(folders, within: { children: :folders }).serialize
    render json: json_string
  end

  def create
    folder = current_user.folders.build(folder_params)
    if folder.save_and_set_position(current_user.final_folder)
      json_string = FolderSerializer.new(folder).serialize
      render json: json_string
    else
      render json: { errors: bookmark.errors.full_messages }, status: 400
    end
  end

  def update
    folder = current_user.folders.find(params[:id])
    if folder.update(folder_params)
      json_string = FolderSerializer.new(folder).serialize
      render json: json_string
    else
      render json: { errors: bookmark.errors.full_messages }, status: 400
    end
  end

  def destroy
    folder = current_user.folders.find(params[:id])
    if folder.destroy
      head :no_content
    else
      render json: { error: 'Failed to destroy.' }, status: 422
    end
  end

  private

  def folder_params
    params.require(:folder).permit(:name, :parent_id, :position)
  end
end
