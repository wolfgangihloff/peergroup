if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  # Read in the config file
  redis_cfg = YAML.load(IO.read("#{Rails.root}/config/redis.yml"))[Rails.env]
  REDIS = Redis.new(redis_cfg) if redis_cfg
end
