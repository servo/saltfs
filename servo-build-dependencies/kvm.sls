kvm-dependencies:
  pkg.installed:
    - pkgs:
      # Also creates the 'kvm' group and gives it permissions to /dev/kvm
      - qemu-kvm

kvm:
  group.present:
    - system: True
    - addusers:
      - servo
