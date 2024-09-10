class UserUpload < Sequel::Model
  many_to_one :user
  many_to_one :upload
end
