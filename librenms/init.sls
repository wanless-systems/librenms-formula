{% from "librenms/map.jinja" import librenms with context %}
librenms_pkgs_install:
  pkg.installed:
    - names: {{ librenms.lookup.pkgs }}

librenms_directory:
  file.directory:
    - name: {{ librenms.general.home }}
    - user: {{ librenms.general.user }}
    - group: {{ librenms.general.group }}

librenms_git:
  git.latest:
    - name: https://github.com/librenms/librenms.git
    - user: {{ librenms.general.user }}
    - target: {{ librenms.general.home }}
    - force_clone: True
    - require:
      - pkg: librenms_pkgs_install
      - user: librenms_user
      - file: librenms_directory

librenms_config:
  file.managed:
    - name: {{ librenms.general.home }}/config.php
    - source: salt://librenms/files/config.php
    - template: jinja
    - user: {{ librenms.general.user }}
    - group: {{ librenms.lookup.webserver_group }}
    - mode: 640
    - require:
      - file: librenms_directory

librenms_user:
  user.present:
    - name: {{ librenms.general.user }}
    - groups:
      - {{ librenms.general.group }}
      - {{ librenms.lookup.webserver_group }}
    - home: {{ librenms.general.home }}
    - shell: /bin/false
    - system: True
    - require:
      - group: librenms_user
  group.present:
    - name: {{ librenms.general.group }}
    - system: True

librenms_log_folder:
  file.directory:
    - name: {{ librenms.general.home }}/logs
    - user: {{ librenms.general.user }}
    - group: {{ librenms.general.group }}
    - recurse:
      - user
      - group
    - mode: 775
    - require:
      - git: librenms_git

librenms_rrd_folder:
  file.directory:
    - name: {{ librenms.general.home }}/rrd
    - user: {{ librenms.general.user }}
    - group: {{ librenms.general.group }}
    - recurse:
      - user
      - group
    - mode: 775
    - require:
      - git: librenms_git

librenms_crontab:
{% if grains['os_family'] == 'FreeBSD' %}
{# FreeBSD has no /etc/cron.d/ and a uses slightly different format #}
  cmd.run:
    - name: "sed 's/  librenms    /  /g' '{{ librenms.general.home }}/librenms.nonroot.cron' > /var/cron/tabs/librenms"
    - onchanges:
      - git: librenms_git
  file.managed:
    - name: /var/cron/tabs/librenms
    - mode: 600
    - user: root
    - group: wheel
{% else %}
  file.managed:
    - name: /etc/cron.d/librenms
    - source: {{ librenms.general.home }}/librenms.nonroot.cron
    - require:
      - git: librenms_git
{% endif %}

librenms_compose_install:
  cmd.run:
    - name: ./scripts/composer_wrapper.php install --no-dev
    - cwd: {{ librenms.general.home }}
    - onchanges:
      - git: librenms_git
