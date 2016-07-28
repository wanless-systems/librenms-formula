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
    - require:
      - git: librenms_git

librenms_rrd_folder:
  file.directory:
    - name: {{ librenms.general.home }}/rrd
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
      - git: librenms_git
      - file: librenms_log_folder
      - file: librenms_rrd_folder

librenms_crontab:
  cron.file:
    - name: {{ librenms.general.home }}/librenms.nonroot.cron
    - user: librenms
    - require:
      - git: librenms_git
