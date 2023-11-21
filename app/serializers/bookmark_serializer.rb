class BookmarkSerializer
  include Alba::Resource

  # 与えられたオブジェクトがコレクションであるかどうかに応じて、返却するJSONのルートキーの単数系・複数形を自動で設定する
  root_key!

  attributes :id, :title, :url

  many :tags, resource: TagSerializer
end
