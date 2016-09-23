/etc/sysctl.conf:
  file.managed:
    - user: root
    - group: wheel
    - mode: 644
    - source: salt://{{ tpldir }}/files/sysctl.conf

/etc/profile:
  file.managed:
    - user: root
    - group: wheel
    - mode: 644
    - source: salt://{{ tpldir }}/files/profile

# Disable Homebrew Analytics
# TODO: wrap this up into a proper state that uses the `brew analytics` command
# instead of directly changing the git configuration
# (requires either upstreaming this state + updating Salt,
# or Salting the Salt master)
# TODO: also ensure the `homebrew.analyticsuuid` setting is unset
disable-homebrew-analytics:
  git.config:
    - name: 'homebrew.analyticsdisabled'
    - value: 'true'
    - repo: /usr/local/Homebrew
