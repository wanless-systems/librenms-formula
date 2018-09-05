{% from "librenms/map.jinja" import librenms with context %}

include:
  - librenms

librenms_build_base:
  cmd.run:
    - cwd: {{ librenms.general.home }}
    - runas: {{ librenms.general.user }}
    - name: php {{ librenms.general.home }}/build-base.php
    - unless: "php {{ librenms.general.home }}/validate.php | grep -E '^DB Schema.*[1-9][0-9]+$'"
    - require:
      - file: librenms_config
