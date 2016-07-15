{% from "librenms/map.jinja" import librenms with context %}
librenms_pkgs_install:
  pkg.installed:
    - names: {{ librenms.lookup.pkgs }}

librenms_git:
  git.latest:
    - name: https://github.com/librenms/librenms.git
    - target: {{ librenms.general.home }}
    - force_clone: True
    - require:
      - pkg: librenms_pkgs_install
      - user: librenms_user

librenms_config:
  file.managed:
    - name: {{ librenms.general.home }}/config.php
    - source: salt://librenms/files/config.php
    - user: {{ librenms.general.user }}
    - group: {{ librenms.general.group }}
    - template: jinja
    - require:
      - git: librenms_git

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
    - user:  {{ librenms.general.user }}
    - group:  {{ librenms.general.group }}
    - require:
      - git: librenms_git

librenms_rrd_folder:
  file.directory:
    - name: {{ librenms.general.home }}/rrd
    - user:  {{ librenms.general.user }}
    - group:  {{ librenms.general.group }}
    - mode: 775
    - require:
      - git: librenms_git

librenms_directory:
  file.directory:
    - name: {{ librenms.general.home }}
    - user: {{ librenms.general.user }}
    - group: {{ librenms.general.group }}
    - recurse:
      - user
      - group
    - require:
      - file: librenms_config
      - file: librenms_log_folder
      - file: librenms_rrd_folder

librenms_crontab:
  cron.file:
    - name: {{ librenms.general.home }}/librenms.nonroot.cron
    - user: librenms
    - require:
      - git: librenms_git
