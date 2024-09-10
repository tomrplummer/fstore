class User < Sequel::Model
  # many_to_many :uploads, join_table: :user_uploads
  many_to_many :uploads, join_table: :user_uploads do |ds|
    ds.select_append(Sequel[:user_uploads][:role]) # Assuming there's a 'role' column in the join table
  end

  dataset_module do
    select :user_list, :id, :full_name, :username, :role
  end
end
