# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set wazuh_master = salt['pillar.get']('wazuh:client:master', default="wazuh") %}
{%- set wazuh_password = salt['pillar.get']('wazuh:client:authid-pass', default="unknown") %}
{%- set agent_name = salt['grains.get']('id') %}

{% from "wazuh/map.jinja" import wazuh with context %}

wazuh-repo:
  file.managed:
    - name: {{ wazuh.client.repo }}
    - source: salt://wazuh/files/{{ wazuh.client.repo_file }}
    - mode: 644
    - user: root
    - group: root

wazuh-client-pkg:
  pkg.installed:
    - name: {{ wazuh.client.pkg }}

# FIXME: Don't distribute the whole file, just change what is needed
wazuh-client-config:
  file.managed:
    - name: {{ wazuh.client.config }}
    - source: salt://wazuh/files/ossec.conf.jinja
    - template: jinja
    - mode: 644
    - user: root
    - group: root

wazuh-agent-registration:
  cmd.run:
    - name: "/var/ossec/bin/agent-auth -A {{ agent_name }} -m {{ wazuh_master }} -P {{ wazuh_password }}" 
    - unless: "grep {{ agent_name }} /var/ossec/etc/client.keys"

wazuh-client-service:
  service.running:
    - name: {{  wazuh.client.service.name }}
    - enable: True


