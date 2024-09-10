class Upload < Sequel::Model
  many_to_many :users, join_table: :user_uploads
  dataset_module do
    where :owned, :role == 'Owned'
  end

  def role
    self[:role]
  end
end
