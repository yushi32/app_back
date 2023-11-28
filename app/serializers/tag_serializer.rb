class TagSerializer
  include Alba::Resource
  
  root_key!

  attributes :id, :name
end
