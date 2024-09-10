require "sinatra"
require "sequel"
require "sequel/plugins/json_serializer"
require "sqlite3"
require "securerandom"
require "jwt"
require "dotenv"
require 'sinatra/reloader' if development?
require_relative './plugins/permitted_params'
require_relative './plugins/route_builder'
require_relative './plugins/paths'
require_relative './helpers/paths_helper'
require_relative './helpers/format_helpers'
require_relative './helpers/auth_helpers'

Dotenv.load

DB = Sequel.connect(ENV["DATABASE_URL"])

Sequel::Model.plugin :json_serializer

Dir.glob("./app/{controllers,models,services}/*.rb").each do |file|
  require file
end

PathsHelper::run
Sinatra::Base.helpers Paths
Sinatra::Base.helpers AuthHelpers
Sinatra::Base.helpers FormatHelpers
Sequel::Model.plugin PermittedParams

use HomeController
use SessionsController
use UsersController
use UploadsController
use UserUploadsController
run Sinatra::Application