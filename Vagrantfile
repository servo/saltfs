require 'yaml'

def extract_id(env)
  id = env.map do |env_var|
    env_var[/^SALT_NODE_ID=(?<node_id>.+)$/, "node_id"]
  end.compact
  id[0]
end

def is_salt_master(id)
  !id.match(/servo-master\d+/).nil?
end

Vagrant.require_version '>= 1.8.0'

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
    if node_config.nil?
      if ENV['VAGRANT_LOG'] == 'debug'
        version = node.has_key?('dist') ? ', version' + node['dist'] : ''
        os_and_version = node['os'] + version
        puts "OS #{os_and_version} is not yet supported"
      end
    elsif node_config[:id] != 'test'
      node_config
    end
  end.compact.uniq.each do |node|
    config.vm.define node[:id] do |machine|
      machine.vm.box = node[:box]
      machine.vm.provider :virtualbox do |vbox|
        # Need extra memory for downloading large files (e.g. Android SDK)
        vbox.memory = 1024
        vbox.linked_clone = true
      end
      machine.vm.synced_folder dir, state_root
      machine.vm.synced_folder File.join(dir, ".travis/test_pillars"), pillar_root
      machine.vm.provision :salt do |salt|
        salt.bootstrap_script = '.travis/install_salt.sh'
        salt.install_args = node[:os] # Pass OS type to bootstrap script
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
