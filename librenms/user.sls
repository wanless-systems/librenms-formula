{% from "librenms/map.jinja" import librenms with context %}
librenms_webusers:
  cmd.run:
    - cwd: {{ librenms.general.home }}
    - names:
      {% for user, option in librenms.config.users.items() %}
      - php adduser.php {{ user }} {{ option.password }} {{ option.level }} {{ option.email }}
      {% endfor %}
    - unless: php validate.php | grep 'DB Schema' | tr -d [A-Z][a-z][[:space:]][:] = ''
