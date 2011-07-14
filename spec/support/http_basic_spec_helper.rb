module HttpBasicSpecHelper
  def login_node
    @request.env["HTTP_AUTHORIZATION"] = %Q{Basic #{ActiveSupport::Base64.encode64("#{NODE_CONFIG[:username]}:#{NODE_CONFIG[:password]}")}}
  end
end
