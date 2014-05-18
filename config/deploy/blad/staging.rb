ask(:ssh_password, "default", echo: false)

server 'axion.webfactional.com', user: fetch(:user), port: 22, password: fetch(:ssh_password), roles: %w{app}
