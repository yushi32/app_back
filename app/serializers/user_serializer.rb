class UserSerializer
  include Alba::Resource
  
  root_key!

  attribute :has_line_user_id do |user|
    user.line_user_id.present?
  end
end
