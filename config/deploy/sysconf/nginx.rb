ask(:ssh_password, "default", echo: false)
set :user, "axion"
set :nginx_app_name, "nginx"
set :nginx_app_port, nil
set :src_dir, "$HOME/src"
set :nginx_package_name, "nginx-1.7.0"

namespace :deploy do
  task :create_nginx_app do
    run_locally do
     filepath = File.expand_path("scripts/create_webfaction_app.rb")
     result = capture("USER=#{fetch(:user)} PASSWORD=#{fetch(:ssh_password)} APP_NAME=#{fetch(:nginx_app_name)} bundle exec ruby '#{filepath}'")
     set :nginx_app_port, JSON.parse(result)["port"]
    end
  end

  task :compile_nginx do
    on roles(:nginx) do |host|
      execute :mkdir, fetch(:src_dir)
      execute("cd #{fetch(:src_dir)}
	      curl -O http://nginx.org/download/#{fetch(:nginx_package_name)}.tar.gz
	      tar -xzvf #{fetch(:nginx_package_name)}.tar.gz")
      execute("cd #{fetch(:src_dir)}/#{fetch(:nginx_package_name)}
              ./configure   --prefix=$HOME/local/nginx  \
	      --sbin-path=$HOME/local/sbin/nginx \
	      --conf-path=$HOME/local/etc/nginx.conf  \
	      --error-log-path=$HOME/logs/user/nginx/error.log \
	      --http-log-path=$HOME/logs/user/nginx/access.log \
	      --pid-path=$HOME/local/run/nginx/nginx.pid \
	      --lock-path=$HOME/local/lock/nginx.lock \
	      --http-client-body-temp-path=$HOME/tmp/nginx/client/ \
	      --http-proxy-temp-path=$HOME/tmp/nginx/proxy/  \
	      --http-fastcgi-temp-path=$HOME/tmp/nginx/fcgi/ \
	      --with-http_flv_module \
	      --with-http_ssl_module \
	      --with-http_gzip_static_module
	      make")
    end
  end

  task :install_nginx do
    on roles(:nginx) do |host|
      execute("cd #{fetch(:src_dir)}/#{fetch(:nginx_package_name)}
  	      make install")
      execute :mkdir, "-p $HOME/tmp/nginx/fcgi $HOME/tmp/nginx/proxy $HOME/tmp/nginx/client"
    end
  end

  task :configure_nginx do
    on roles(:nginx) do |host|
      execute :mv, "$HOME/local/etc/nginx.conf $HOME/local/etc/nginx.conf.backup"
      template = Erubis::Eruby.new(File.read('assets/nginx.conf.eruby'))
      upload! StringIO.new(template.result(port: fetch(:nginx_app_port))), "/tmp/nginx.conf"
      execute "mv /tmp/nginx.conf $HOME/local/etc/nginx.conf"
    end
  end

  desc "install nginx on the nginx server"
  task :install do
    on roles(:nginx) do |host|
      invoke "deploy:create_nginx_app"
      invoke "deploy:compile_nginx"
      invoke "deploy:install_nginx"
      invoke "deploy:configure_nginx"
    end
  end
end

