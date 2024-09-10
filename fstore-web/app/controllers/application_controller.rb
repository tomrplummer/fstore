require "sinatra/base"
require "sinatra/reloader" if development?
require "sinatra/flash"
require "logger"
require "active_support"
require_relative "../../helpers/error"

class ApplicationController < Sinatra::Base
  use Rack::MethodOverride
  extend ActiveSupport::Inflector
  register Sinatra::Flash
  include Err
  enable :sessions

  @logger = Logger.new $stdout

  configure do
    set :jwt_secret, secret: ENV["JWT_SECRET"]
  end

  configure :development do
    register Sinatra::Reloader
  end

  set :public_folder, File.join(root, "..", "public")

  set :views, -> {
    File.expand_path(
      "../../app/views/",
      File.dirname(__FILE__)
    )
  }

  # Sets or gets the base name for a class
  def self.base_name(name = nil)
    @base_name = name if name
    @base_name
  end

  # Sets or gets the association name this class belongs to
  def self.belongs_to(name = nil)
    @belongs_to = name if name
    @belongs_to
  end

  def self.as(name = nil)
    @as = name if name
    @as
  end

  # Returns the base name set for the instance's class
  def base_name
    self.class.base_name
  end

  # Returns the belongs_to association set for the instance's class
  def belongs_to
    self.class.belongs_to
  end

  def as
    self.class.as
  end
=begin


    def post(*args, &block)
      args[0] = build_route(args[0])
      super(*args, &block)
    rescue
      puts args, block
    end

    def put(*args, &block)
      args[0] = build_route(args[0])
      super(*args, &block)
    rescue
      puts args, block
    end

    def delete(*args, &block)
      args[0] = build_route(args[0])
      super(*args, &block)
    rescue
      puts args, block
    end
    def build_route(route_name)
      if route_name.is_a?(String)
        full_route = "#{route_name}"
      else
        if @as
          @base_name = @as
        end
        full_route = case route_name
        when :index
          route_base + "/#{@base_name}"
        when :new
          route_base + "/#{@base_name}/new"
        when :show
          "/#{@base_name}/:id"
        when :edit
          "/#{@base_name}/:id/edit"
        when :create
          route_base + "/#{@base_name}"
        when :update
          "/#{@base_name}/:id"
        when :destroy
          "/#{@base_name}/:id"
        else
          ""
        end
        puts "#{route_name} #{full_route}"
      end
      full_route
    end
    def route_base
      if @belongs_to
        "/#{@belongs_to}/:#{@belongs_to.to_s.singularize}_id"
      else
        ""
      end
    end
  end
=end
  post "/unauthenticated" do
    redirect "/login"
  end
end
