require 'yaml'

def extract_id(env)
  id = env.split.map do |env_var|
    env_var[/^SALT_NODE_ID=(?<node_id>.+)$/, "node_id"]
  end.compact
  id[0]
end

Vagrant.configure(2) do |config|

  YAML.load_file('.travis.yml')['matrix']['include'].map do |node|
    node_config = case node['os']
    when 'linux'
      case node['dist']
      when 'trusty'
        { id: extract_id(node['env']), os: node['os'], box: 'ubuntu/trusty64' }
      end
    end
    if node_config.nil? && ENV['VAGRANT_LOG'] == 'debug'
      version = node.has_key?('dist') ? ', version' + node['dist'] : ''
      os_and_version = node['os'] + version
      puts "OS #{os_and_version} is not yet supported"
    else
      node_config
    end
  end.compact.each do |node|
    config.vm.define node[:id] do |machine|
      machine.vm.box = node[:box]
      machine.vm.synced_folder ".",  "/srv/salt/states"
      machine.vm.synced_folder ".travis/test_pillars", "/srv/salt/pillars"
      machine.vm.provision :salt do |salt|
        salt.bootstrap_script = '.travis/install_salt'
        salt.install_command = node[:os] # Pass OS type to install_salt script
        salt.masterless = true
        salt.minion_config = '.travis/minion'
        # hack to provide additional options to salt-call
        salt.minion_id = node[:id] + ' --retcode-passthrough'
        salt.run_highstate = true
        salt.verbose = true
        salt.log_level = 'info'
        salt.colorize = true
      end
    end
  end

end
