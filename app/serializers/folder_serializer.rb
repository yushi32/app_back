class FolderSerializer
  include Alba::Resource

  root_key!

  attributes :id, :name, :parent_id

  many :children, resource: FolderSerializer
end
