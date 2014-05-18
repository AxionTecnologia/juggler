# Load DSL and Setup multiple configurations
# https://github.com/railsware/capistrano-multiconfig
require 'capistrano/deploy'
require 'capistrano/multiconfig'
require 'json'
require 'erubis'

# Loads custom tasks
Dir.glob('tasks/*.rake').each { |r| import r }
