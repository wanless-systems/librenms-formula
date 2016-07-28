{% from "librenms/map.jinja" import librenms with context %}

include:
  - librenms

librenms_webusers:
  cmd.run:
    - cwd: {{ librenms.general.home }}
    - onlyif: "php validate.php | grep -E '^DB Schema: [0-9]+$'"
    - names:
      {% for user, option in librenms.config.users.items() %}
      - php adduser.php {{ user }} {{ option.password }} {{ option.level }} {{ option.email }}
      {% endfor %}
    - require:
      - file: librenms_config
