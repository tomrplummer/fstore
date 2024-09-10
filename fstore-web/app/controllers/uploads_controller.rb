require 'haml'

class UploadsController < ApplicationController
  base_name :uploads
  belongs_to nil
  as nil

  set(:filter) do |filter_val|
    condition do
      params['filter'] == filter_val.to_s
    end
  end

  get '/uploads', filter: :owned do
    authenticate request

    user = User.find(id: current_user[:id])

    @uploads = user.uploads.select { |upload| upload[:role] == 'owner' }
    haml :uploads_index
  end

  get '/uploads', filter: :shared do
    authenticate request

    user = User.find(id: current_user[:id])

    @uploads = user.uploads.select { |upload| upload[:role] != 'owner' }

    haml :uploads_index
  end

  get '/uploads' do
    authenticate request

    user = User.find(id: current_user[:id])
    @uploads = user.uploads
    haml :uploads_index
  end

  get '/uploads/new' do
    @upload = Upload.new
    haml :uploads_new
  end

  get '/uploads/show' do |id|
    @upload = Upload.find(id:)
    haml :uploads_show
  end

  get '/uploads/:id/edit' do |id|
    @upload = Upload.find(id:)
    @user_uploads = DB['select uu.*, u.full_name from user_uploads uu inner join users u on u.id == uu.user_id where uu.upload_id = ?',
                       id].all
    @users = User.user_list
    haml :uploads_edit
  end

  get '/uploads/:id/download' do |id|
    authenticate request

    upload = Upload.find(id:)

    uploads_service = UploadsService.new(params, current_user)
    result = uploads_service.download_file(upload.guid, upload.bytes)
    error_response result[:error] do
    end

    content_type 'application/octet-stream'
    attachment upload.file_name

    result[:file]
  end

  post '/uploads' do
    authenticate request

    uploads_service = UploadsService.new params, current_user
    result = uploads_service.create_upload
    error_response(result[:error]) do
      recover :rest do
        @upload = Upload.new Upload.permitted(params)
        redirect new_upload_path
      end
    end

    redirect '/uploads'
  end

  put '/uploads/:id' do |_id|
    authenticate request

    uploads_service = UploadsService.new params, current_user
    result = uploads_service.update_upload

    error_response result[:error] do
      recover :rest do
        @upload = Upload.new Upload.permitted(params)
        flash[:error] = result[:message]
        redirect "/uploads/#{params[:id]}/edit"
      end
    end

    flash[:notice] = 'File updated'
    redirect "/uploads/#{params[:id]}/edit"
  end

  delete '/uploads/:id' do |id|
    upload = Upload.find(id:)
    upload.destroy
    redirect '/uploads'
  end
end
