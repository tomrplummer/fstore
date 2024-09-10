require 'haml'

class HomeController < ApplicationController
  get '/' do
    status, headers, body = call env.merge("PATH_INFO" => "/uploads")
    [status, headers, body] # Return the response of /first_route
    # respond_to do
    #   json {{message: "Coming Soon"}}
    #   html {haml :home_index}
    # end
  end
end
