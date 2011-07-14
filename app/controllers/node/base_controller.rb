class Node::BaseController < ApplicationController
  before_filter :authenticate_node

  def authenticate_node
    authenticate_or_request_with_http_basic do |username, password|
      username == NODE_CONFIG[:username] && password == NODE_CONFIG[:password]
    end
  end
end
