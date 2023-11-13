class BookmarkSerializer
  include JSONAPI::Serializer

  attributes :id, :url, :title
end
