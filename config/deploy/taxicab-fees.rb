#Información básica
set :application, "taxicab_fees"
set :repo_url,  "git@github.com:minostro/taxicab-fees.git"
#Configuración del SCM.
#Se copiarán los archivos por cada deploy
set :scm, :git
set :deploy_via,  :copy
set :copy_strategy, :export
set :ssh_options, { :forward_agent => true}
#Se deshabilita el uso de sudo
set :use_sudo, false
#Se configura el usuario del host
set :user, 'axion'
set :tmp_dir, "/home/axion/tmp"
set :deploy_to, "/home/axion/webapps/taxicab_fees"

before 'deploy:finishing', 'deploy:copy_settings'
before 'deploy:finishing', 'deploy:set_up_virtualenv'
before 'deploy:finishing', 'deploy:copy_server_files'
before 'deploy:finishing', 'deploy:generate_static_files'
before 'deploy:finishing', 'deploy:restart_nginx'
before 'deploy:finishing', 'deploy:restart_tornado'


namespace :deploy do
  task :copy_settings do
    on roles(:app) do |host|
      upload! File.open('assets/taxicab-fees/settings.py'), "#{fetch(:release_path)}/taxicab_fees/taxicab_fees/settings.py"
      upload! File.open("assets/taxicab-fees/manage.py"), "#{fetch(:release_path)}/taxicab_fees/manage.py"
      upload! File.open("assets/taxicab-fees/nginx.conf"), "/home/axion/local/etc/nginx/taxicab_fees.conf"
      upload! File.open("assets/taxicab-fees/taxicab-fees.ini"), "/home/axion/local/etc/supervisord/taxicab_fees.ini"
    end
  end

  task :set_up_virtualenv do
    on roles(:app) do |host|
      within release_path do
        execute :bash, "-l -c 'virtualenv .'"
        execute :bash, "-l -c 'source bin/activate && pip install -r requirements/production.txt'"
      end
    end
  end

  task :copy_server_files do
    on roles(:app) do |host|
      ["server.py", "activate_this.py"].each do |file|
        upload! File.open("assets/taxicab-fees/#{file}"), "#{fetch(:release_path)}/#{file}"
      end
    end
  end

  task :generate_static_files do
    on roles(:app) do |host|
      within "#{fetch(:release_path)}/taxicab_fees" do
        execute :bash, "-l -c 'python2.7 manage.py collectstatic -v0 --noinput'"
      end
    end
  end

  task :restart_nginx do
    on roles(:app) do |host|
      condition = "test -f /home/axion/local/run/nginx/nginx.pid"
      nginx = "nginx -c /home/axion/local/etc/nginx.conf"
      stop_nginx = "#{nginx} -s stop"
      reload_nginx = "#{nginx} -s reload"
      execute("PATH=/home/axion/local/sbin:$PATH; if #{condition}; then #{stop_nginx}; fi")
      execute(". /etc/init.d/functions; PATH=/home/axion/local/sbin:$PATH; daemon #{nginx}")
      execute("PATH=/home/axion/local/sbin:$PATH; #{reload_nginx}")
    end
  end

  task :restart_tornado do
    on roles(:app) do |host|
      execute("if test -f $HOME/tmp/supervisord.pid; then cat $HOME/tmp/supervisord.pid | xargs kill -s SIGTERM; fi")
      execute("PATH=$HOME/bin:$PATH; supervisord -c /home/axion/local/etc/supervisord.conf")
      execute(". /etc/init.d/functions; PATH=$HOME/bin:$PATH; daemon supervisorctl -c /home/axion/local/etc/supervisord.conf start all")
      execute("PATH=$HOME/bin:$PATH; supervisorctl -c /home/axion/local/etc/supervisord.conf reread")
      execute("PATH=$HOME/bin:$PATH; supervisorctl -c /home/axion/local/etc/supervisord.conf update")
    end
  end
end
