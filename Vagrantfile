require 'yaml'

def extract_id(env)
  id = env.split.map do |env_var|
    env_var[/^SALT_NODE_ID=(?<node_id>.+)$/, "node_id"]
  end.compact
  id[0]
end

Vagrant.require_version '>= 1.8.0'

Vagrant.configure(2) do |config|

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :machine
  end

  dir = File.dirname(__FILE__)
  minion_config = YAML.load_file(File.join(dir, '.travis/minion'))

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
  end.compact.each do |node|
    config.vm.define node[:id] do |machine|
      machine.vm.box = node[:box]
      machine.vm.provider :virtualbox do |vbox|
        # Need extra memory for downloading large files (e.g. Android SDK)
        vbox.memory = 1024
        vbox.linked_clone = true
      end
      machine.vm.provision :salt do |salt|
        salt.bootstrap_script = '.travis/install_salt.sh'
        salt.install_args = node[:os] # Pass OS type to bootstrap script
        salt.masterless = true
        salt.minion_config = '.travis/minion'
        # hack to provide additional options to salt-call
        salt.minion_id = node[:id] + ' ' + ([
            '--file-root=/vagrant',
            '--pillar-root=/vagrant/.travis/test_pillars',
            '--retcode-passthrough'
        ].join(' '))
        salt.run_highstate = true
        salt.verbose = true
        salt.log_level = 'info'
        salt.colorize = true
      end
    end
  end

end
