Sequel.migration do
  change do
    create_table(:user_uploads) do
      primary_key :id
      Integer :user_id
      Integer :upload_id

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
