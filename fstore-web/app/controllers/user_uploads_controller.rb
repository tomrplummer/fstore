require 'haml'

class UserUploadsController < ApplicationController
  base_name :user_uploads
  belongs_to :uploads
  as nil

  get :index do |_upload_id|
    # @user_uploads = UserUpload.where(upload_id: params[:upload_id]).all
    @user_uploads = DB['select uu.*, u.full_name from user_uploads uu inner join users u on u.id == uu.user_id where uu.upload_id = ?',
                       params[:upload_id]].all
    respond_to do
      json { @user_uploads }
      html { haml :user_uploads_index }
    end
  end

  get '/uploads/:upload_id/user_uploads/new' do |upload_id|
    @upload_id = upload_id
    @user_list = DB['Select u.id, u.username, u.full_name from users u left join user_uploads uu on u.id = uu.user_id and uu.upload_id = ? where uu.user_id is null',
                    upload_id].all
    haml :user_uploads_new
  end

  get :show do |id|
    @user_upload = UserUpload.find(id:)
    haml :user_uploads_show
  end

  get :edit do |id|
    @user_upload = UserUpload.find(id:)
    haml :user_uploads_edit
  end

  post "/uploads/:upload_id/user_uploads" do |upload_id|
    user_upload = UserUpload.create UserUpload.permitted(params.merge(upload_id:)) if params[:share]
    redirect new_user_upload_path(id: upload_id)
  end

  put :update do |id|
    user_upload = UserUpload.find(id:)
    user_upload.update UserUpload.permitted(params)
    redirect "/shares/#{params[:id]}"
  end

  delete :destroy do |id|
    user_upload = UserUpload.find(id:)
    user_upload.destroy
    redirect '/shares'
  end
end
