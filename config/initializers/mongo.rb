if ENV['MONGOHQ_URL']
  MongoMapper.config = {RAILS_ENV => {'uri' => ENV['MONGOHQ_URL']}}
else
  # Read in the config info 
  mongo_cfg = YAML.load( IO.read("#{RAILS_ROOT}/config/mongodb.yml") )[RAILS_ENV]

  # Create the connection from mongodb.yml 
  conn_args = [mongo_cfg['host'],mongo_cfg['port']].compact
  MongoMapper.connection = Mongo::Connection.new(*conn_args)

  # Pick the Mongo database 
  db_cfg = Rails.configuration.database_configuration[RAILS_ENV]
  MongoMapper.database = mongo_cfg['database'] || db_cfg['database']
end

MongoMapper.connect(RAILS_ENV)





