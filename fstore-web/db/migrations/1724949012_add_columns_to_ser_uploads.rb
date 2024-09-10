Sequel.migration do
  change do
    add_column :user_uploads, :role, String
  end
end
