set :nginx_app_name, "nginx"
set :nginx_app_port, nil
set :nginx_package_name, "nginx-1.7.0"

namespace :deploy do
  task :install_supervisor do
    on roles(:supervisor) do |host|
      execute("PATH=$HOME/bin:$PATH
              mkdir -p $HOME/local/etc/supervisord
	      pip2.7 install supervisor")
    end
  end

  task :configure_supervisor do
    on roles(:supervisor) do |host|
      template = Erubis::Eruby.new(File.read('assets/supervisord.conf.eruby'))
      upload! StringIO.new(template.result(tmp: fetch(:tmp_dir), files: "#{fetch(:local_dir)}")), "/tmp/supervisord.conf"
      execute "mv /tmp/supervisord.conf #{fetch(:local_dir)}/etc/supervisord.conf"
    end
  end

  desc "install supervisor on the server"
  task :install do
    on roles(:supervisor) do |host|
      invoke "deploy:install_supervisor"
      invoke "deploy:configure_supervisor"
    end
  end

  task :start do
    on roles(:supervisor) do |host|
      execute("PATH=$HOME/bin:$PATH; supervisord")
    end
  end
end

