class FolderSerializer
  include Alba::Resource

  root_key!

  attributes :id, :name

  many :children, resource: FolderSerializer
end
