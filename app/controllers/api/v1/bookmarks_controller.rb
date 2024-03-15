class Api::V1::BookmarksController < Api::V1::BaseController
  def index
    bookmarks = current_user.bookmarks.includes(:tags).order(created_at: :desc)
    json_string = BookmarkSerializer.new(bookmarks).serialize
    render json: json_string
  end

  def create
    bookmark = current_user.bookmarks.build(bookmark_params)
    auto_generate_tag = bookmark.generate_tag_from_url
    if bookmark.save_with_tags(auto_generate_tag, current_user)
      json_string = BookmarkSerializer.new(bookmark).serialize
      render json: json_string
    else
      render json: { errors: bookmark.errors.full_messages }, status: 400
    end
  end

  def update
    bookmark = current_user.bookmarks.includes(:tags).find(params[:id])
    bookmark.assign_attributes(bookmark_params)
    if bookmark.save_with_tags(params.dig(:bookmark, :tag_name), current_user)
      json_string = BookmarkSerializer.new(bookmark).serialize
      render json: json_string
    else
      render json: { errors: bookmark.errors.full_messages }, status: 400
    end
  end

  def destroy
    bookmark = current_user.bookmarks.find(params[:id])
    if bookmark.destroy
      head :no_content
    else
      render json: { error: 'Failed to destroy.' }, status: 422
    end
  end

  def check_duplicate
    existing_bookmark = current_user.bookmarks.find_by(url: params[:url])

    if existing_bookmark
      render json: { duplicate: true }
    else
      render json: { duplicate: false }
    end
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:url, :title, :thumbnail, :note, :status, :folder_id)
  end
end
