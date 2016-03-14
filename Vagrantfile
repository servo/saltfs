require 'yaml'

def extract_id(env)
  id = env.split.map do |env_var|
    env_var[/^SALT_NODE_ID=(?<node_id>.+)$/, "node_id"]
  end.compact
  id[0]
end

Vagrant.configure(2) do |config|

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :machine
  end

  dir = File.dirname(__FILE__)
  minion_config = YAML.load_file(File.join(dir, '.travis/minion'))
  state_root = minion_config['file_roots']['base'][0]
  pillar_root = minion_config['pillar_roots']['base'][0]

  YAML.load_file(File.join(dir,'.travis.yml'))['matrix']['include'].map do |node|
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
      machine.vm.provider :virtualbox do |vbox|
        # Need extra memory for downloading large files (e.g. Android SDK)
        vbox.memory = 1024
        if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')
          vbox.linked_clone = true
        end
      end
      machine.vm.synced_folder dir, state_root
      machine.vm.synced_folder File.join(dir, ".travis/test_pillars"), pillar_root
      machine.vm.hostname = node[:id]
      machine.vm.provision :salt do |salt|
        salt.bootstrap_script = '.travis/install_salt'
        salt.install_args = node[:os] # Pass OS type to install_salt script
        salt.masterless = true
        salt.minion_config = '.travis/minion'
        salt.run_highstate = true
        salt.verbose = true
        salt.log_level = 'info'
        salt.colorize = true
      end
    end
  end

end
