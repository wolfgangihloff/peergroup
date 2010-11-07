if ENV['MONGOHQ_URL']
  MongoMapper.config = {Rails.env => {'uri' => ENV['MONGOHQ_URL']}}
  MongoMapper.connect(Rails.env)
else
  # Read in the config info 
  mongo_cfg = YAML.load( IO.read("#{Rails.root}/config/mongodb.yml") )[Rails.env]

  # Create the connection from mongodb.yml 
  conn_args = [mongo_cfg['host'],mongo_cfg['port']].compact
  MongoMapper.connection = Mongo::Connection.new(*conn_args)

  # Pick the Mongo database 
  db_cfg = Rails.configuration.database_configuration[Rails.env]
  MongoMapper.database = mongo_cfg['database'] || db_cfg['database']
end

