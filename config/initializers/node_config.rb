# Create seperate config file when node will be moved from rails app repository
NODE_CONFIG = ActiveSupport::JSON.decode(File.read(Rails.root.join("app-node", "config.json"))).symbolize_keys
