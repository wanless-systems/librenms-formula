{% from "librenms/map.jinja" import librenms with context %}
librenms_check_install:
  file.exists:
    - name: {{ librenms.general.home }}/build-base.php

librenms_build_base:
  cmd.run:
    - cwd: {{ librenms.general.home }}
    - name: php {{ librenms.general.home }}/build-base.php
    - require:
      - file: librenms_check_install
