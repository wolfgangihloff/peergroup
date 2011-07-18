namespace :spec do
  desc "Start node server for testing"
  task :start_node do
    system("cd app-node && REDIS_DB=1 NODE_ENV=test node server.js")
  end
end
