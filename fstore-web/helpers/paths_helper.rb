require "toml-rb"
require_relative '../plugins/route_builder'
require_relative '../plugins/paths'

module PathsHelper
  extend RouteBuilder
  include Paths
  def self.run
    config = TomlRB.load_file(File.expand_path('./helpers/paths_config.toml'))

    unless config["resources"].nil?
      config["resources"].each do |resource|
        # if resource["as"].nil?
        #   resources resource["name"].to_sym
        # else
        #   resources resource["name"].to_sym, :as => resource["as"].to_sym
        # end
        resources resource["name"].to_sym, :as => resource["as"]&.to_sym, :belongs_to => resource["belongs_to"]&.to_sym
      end
    end

    # put resources here
  end
end
