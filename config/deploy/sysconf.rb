ask(:ssh_password, "default", echo: false)
set :user, "axion"
set :src_dir, "/home/axion/src"
set :tmp_dir, "/home/axion/tmp"
set :local_dir, "/home/axion/local"

namespace :deploy do
  task :setup do
    on roles(:all) do |host|
      execute("mkdir -p $HOME/src
               mkdir -p $HOME/local/sbin
	       mkdir -p $HOME/local/etc")
      execute("easy_install-2.7 virtualenv
	      easy_install-2.7 argparse
              easy_install-2.7 pip")
    end
  end
end
