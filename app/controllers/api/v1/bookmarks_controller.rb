class Api::V1::BookmarksController < Api::V1::BaseController
  def index
    bookmarks = current_user.bookmarks.order(created_at: :desc)
    json_string = BookmarkSerializer.new(bookmarks).serializable_hash.to_json
    render json: json_string
  end

  def create
    bookmark = current_user.bookmarks.build(bookmark_params)
    if bookmark.save
      json_string = BookmarkSerializer.new(bookmark).serializable_hash.to_json
      render json: json_string
    else
      render json: {errors: bookmark.errors.full_messages}, status: 400
    end
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:url, :title)
  end
end
