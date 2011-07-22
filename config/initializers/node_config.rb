NODE_CONFIG = {
  :username => ENV["NODE_USER"]     || "node",
  :password => ENV["NODE_PASSWORD"] || "secret",
  :protocol => ENV["NODE_PROTOCOL"] || "http",
  :host     => ENV["NODE_HOST"]     || "localhost",
  :port     => ENV["NODE_PORT"]     || "8081"
}
