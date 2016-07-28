{% from "librenms/map.jinja" import librenms with context %}

include:
  - librenms

librenms_build_base:
  cmd.run:
    - cwd: {{ librenms.general.home }}
    - name: php {{ librenms.general.home }}/build-base.php
    - unless: "php validate.php | grep -E '^DB Schema: [0-9]+$'"
    - require:
      - file: librenms_config
