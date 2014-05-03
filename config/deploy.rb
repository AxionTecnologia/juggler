#
# Put here shared configuration shared among all children
#
# Read more about configurations:
# https://github.com/railsware/capistrano-multiconfig/blob/master/README.md

set :scm, :git
set :format, :pretty
set :log_level, :debug
set :keep_releases, 10

task :hola do
  puts "as"
end
