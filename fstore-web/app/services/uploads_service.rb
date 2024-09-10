require "securerandom"
require "ffi"
require_relative "../../lib/file_reader"
require_relative "../../lib/uploader"

class UploadsService
  def initialize(params = {}, current_user = {})
    @params = params
    @current_user = current_user
    @ul_host = ENV["UL_ADDR"]
    @dl_host = ENV["DL_ADDR"]
    @ul_port = ENV["UL_PORT"]
    @dl_port = ENV["DL_PORT"]
  end

  def create_upload
    return {error: Err.access_denied} if @current_user.nil?

    file = @params[:file]
    return {error: Err.unproccessable_entity, message: "No file found"} if file.nil?
    file_name = filename_from_params
    bytes = file[:tempfile].size
    guid = SecureRandom.uuid

    upload_payload = {
      file_name: file_name,
      bytes: bytes,
      public: 0,
      guid: guid
    }

    result = upload_file file, guid

    return result if result[:error]

    DB.transaction do
      begin
        upload = Upload.new upload_payload
        upload_result = upload.save

        user_upload_payload = {
          user_id: @current_user[:id],
          upload_id: upload_result[:id],
          role: "owner"
        }

        user_upload = UserUpload.new user_upload_payload
        user_upload.save

        return {success: true, id: upload}
      rescue => e
        Sequel::Rollback
        return {error: Err.server_error, message: e}
      end
    end
  end

  def upload_file(uploaded_file, file_id)
    begin
      file_size = File.size? uploaded_file[:tempfile]
      size_ptr = FFI::MemoryPointer.new(:int)
      data_ptr = FileReader.ReadFile(uploaded_file[:tempfile].path, size_ptr)
      size = size_ptr.read_int
      file_content = data_ptr.read_bytes(size)

      file_name = filename_from_params

      file_pointer = FFI::MemoryPointer.from_string(file_content)

      result = Uploader.UploadFile(file_id, file_pointer, file_size, @ul_host, @ul_port)
      return {error: Err.server_error, message: result} if /^error/.match? result.downcase
      {success: true, message: result}
    rescue => e
      {error: Err.server_error, message: e}
    end
  end

  def download_file(file_id, file_size)
      _CHUNK_SIZE = 1024 * 64
      request = "#{file_id}\n#{file_size}"

      begin
        socket = TCPSocket.new(@dl_host, @dl_port)
        socket.write(request)

        file = ''
        c = 0
        while (chunk = socket.read(_CHUNK_SIZE))
          c += 1
          file << chunk
        end
        {success: true, file: file}
      rescue => e
        {error: Err.server_error, message: e}
      ensure
        socket.close if socket
      end
    end

  def update_upload
    return {error: Err.unproccessable_entity, message: "The file must have a name"} unless validate_filename

    @params[:public] = @params[:public].nil? ? 0 : 1

    upload = Upload.find(id: @params[:id])
    return {error: Err.not_found, message: "File not found"} if upload.nil?

    begin
      upload.update Upload.permitted(@params)
    rescue => e
      return {error: Err.server_error, message: e}
    end

    {success: true, id: @params[:id]}
  end

  private

  def has_file
    !!@params[:file]
  end

  def filename_from_params
    @params[:file_name] || @params[:file][:filename]
  end

  def validate_filename
    return !@params[:file_name].nil? && @params[:file_name] != ""
  end
end
