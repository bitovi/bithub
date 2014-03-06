
def execute_interactively(*args)
  user = fetch(:user)
  port = fetch(:port) || 22

  remote_command = [
    env_to_s,
    '/usr/bin/env',
    SSHKit::Command.new(*args).to_s
  ].join(' ')

  exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{remote_command}'"
end

def env_to_s(vars={})
  stage = fetch(:stage)
  env = fetch(:default_env).merge({env: stage, rails_env: stage})
  env.map {|k,v| "#{k.to_s.upcase}=#{v}"}.join ' '
end
