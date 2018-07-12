kvm-dependencies:
  pkg.installed:
    - pkgs:
      # Also creates the 'kvm' group and gives it permissions to /dev/kvm
      - qemu-kvm

kvm-group:
  user.present:
    - require:
      - pkg: kvm-dependencies
    - groups:
      - kvm
