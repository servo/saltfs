require 'yaml'

def extract_id(env)
  id = env.map do |env_var|
    env_var[/^SALT_NODE_ID=(?<node_id>.+)$/, "node_id"]
  end.compact
  id[0]
end

def is_salt_master(id)
  # The ideal way of doing this would be to ask Salt, which minions will
  # execute the `salt/master.sls` state file during a highstate? However,
  # it is not possible to do that from Vagrant outside the VM, and parsing
  # the top.sls is also not a good idea because there are Salt intracacies
  # like compound matching. Hence, simply hardcode this regex for now.
  # This should be kept in sync with the top.sls file.
  !id.match(/servo-master\d+/).nil?
end

# Need Vagrant >= 1.8.0, in which the Vagrant Salt provisioner was overhauled
# See https://github.com/servo/saltfs/pull/180
# Vagrant 1.8.3+ breaks our usage of minion_id to pass additional args to Salt
# See https://github.com/mitchellh/vagrant/pull/7207
Vagrant.require_version('>= 1.8.0', "< 1.8.3")

Vagrant.configure(2) do |config|

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :machine
  end

  dir = File.dirname(__FILE__)
  test_pillars_path = File.join(dir, '.travis', 'test_pillars')

  YAML.load_file(File.join(dir, '.travis.yml'))['matrix']['include'].map do |node|
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
      if is_salt_master(node[:id])
        # Salt master directories are hardcoded because we'd need to run Salt
        # to resolve the configuration stored in the salt/map.jinja file.
        # Make sure to keep these values in sync with that file.
        # Note that because gitfs always reflects the master branch on GitHub,
        # the states dir is synced to the override location instead to allow
        # testing out changes locally.
        machine.vm.synced_folder dir, '/tmp/salt-testing-root/saltfs'
        machine.vm.synced_folder test_pillars_path, '/srv/pillar'
      end
      machine.vm.provision :salt do |salt|
        salt.bootstrap_script = File.join(dir, '.travis', 'install_salt.sh')
        salt.install_args = node[:os] # Pass OS type to bootstrap script
        salt.masterless = true
        salt.minion_config = File.join(dir, '.travis', 'minion')
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
