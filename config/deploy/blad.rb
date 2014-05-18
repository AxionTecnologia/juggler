#Información básica
set :application, "blad"
set :repo_url,  "git@github.com:AxionTecnologia/bus-lines-admin.git"
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
set :deploy_to, "/home/axion/webapps/#{fetch(:application)}"

before 'deploy:finishing', 'deploy:copy_settings'
before 'deploy:finishing', 'deploy:set_up_virtualenv'
before 'deploy:finishing', 'deploy:copy_server_files'
before 'deploy:finishing', 'deploy:generate_static_files'
before 'deploy:finishing', 'deploy:restart_nginx'
before 'deploy:finishing', 'deploy:restart_tornado'


namespace :deploy do
  task :copy_settings do
    on roles(:app) do |host|
      upload! File.open('assets/blad/settings.py'), "#{fetch(:release_path)}/blad/blad/settings.py"
      upload! File.open("assets/blad/manage.py"), "#{fetch(:release_path)}/blad/manage.py"
      upload! File.open("assets/blad/nginx.conf"), "/home/axion/local/etc/nginx/blad.conf"
      upload! File.open("assets/blad/blad.ini"), "/home/axion/local/etc/supervisord/blad.ini"
    end
  end

  task :set_up_virtualenv do
    on roles(:app) do |host|
      within release_path do
        execute :bash, "-l -c 'python2.7 environment.py --create'"
      end
    end
  end

  task :copy_server_files do
    on roles(:app) do |host|
      ["server.py", "activate_this.py"].each do |file|
        upload! File.open("assets/blad/#{file}"), "#{fetch(:release_path)}/#{file}"
      end
    end
  end

  task :generate_static_files do
    on roles(:app) do |host|
      within "#{fetch(:release_path)}/blad" do
        execute :python, "manage.py collectstatic -v0 --noinput"
      end
    end
  end

  task :restart_nginx do
    on roles(:app) do |host|
      execute("PATH=/home/axion/local/sbin:$PATH; nginx -s reload")
    end
  end

  task :restart_tornado do
    on roles(:app) do |host|
      execute("PATH=$HOME/bin:$PATH; supervisorctl restart blad")
    end
  end
end
