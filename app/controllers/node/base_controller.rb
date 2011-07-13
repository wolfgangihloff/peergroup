class Node::BaseController < ApplicationController
  # protect_from_forgery :only => []
  before_filter :authenticate_node

  def authenticate_node
    authenticate_or_request_with_http_basic do |username, password|
      username == "node" && password == "secret"
    end
  end
end
