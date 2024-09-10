Sequel.migration do
  change do
    create_table(:uploads) do
      primary_key :id
      String :file_name
      String :guid
      Integer :bytes
      Integer :public, default: 0

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
