#
# Cookbook:: heroes_app
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.

# Se Instala Node.js
execute 'install_nodejs' do
  command 'curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs'
  not_if 'which node'
end

# Instala git
package 'git'

# Clona el repositorio desde git con la app Vite + React
git '/home/vagrant/react_app' do
  repository 'https://github.com/anajcorona/07-heroes-spa'
  revision 'main'
  action :sync
  user 'vagrant'
end

# Instala dependencias de la app
execute 'npm_install' do
  cwd '/home/vagrant/react_app'
  command 'npm install'
  user 'vagrant'
  environment 'HOME' => '/home/vagrant'
end

# Instla service globalmente
execute 'install_serve' do
  command 'npm install -g serve'
  not_if 'which serve'
end

# Ejecuta el comando para construir la app
execute 'npm_run_build' do
  cwd '/home/vagrant/react_app'
  command 'npm run build'
  user 'vagrant'
  environment 'HOME' => '/home/vagrant'
end

# Crea un servicio systemd que permite iniciar, detener o reiniciar la app
file '/etc/systemd/system/react_app.service' do
  content <<-EOF
[Unit]
Description=React App Service
After=network.target

[Service]
User=vagrant
WorkingDirectory=/home/vagrant/react_app
ExecStart=/usr/bin/serve -s dist --listen tcp://0.0.0.0:3000
Restart=always
Environment=HOME=/home/vagrant

[Install]
WantedBy=multi-user.target
EOF
  mode '0644'
end

# Ejecuta la app
execute 'enable_and_start_service' do
  command 'systemctl daemon-reload && systemctl enable react_app && systemctl start react_app'
end

