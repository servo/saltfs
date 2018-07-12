kvm-dependencies:
  pkg.installed:
    - pkgs:
      # We don’t actually use the contents of this package,
      # installing it makes /dev/kvm be usable by the 'kvm' Unix group
      # (and makes that group exist).
      - libvirt-bin

kvm-group:
  user.present:
    - require:
      - pkg: kvm-dependencies
    - groups:
      - kvm
