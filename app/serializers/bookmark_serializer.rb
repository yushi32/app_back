class BookmarkSerializer
  include JSONAPI::Serializer

  attributes :url, :title
end
