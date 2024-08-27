#!/bin/bash
ansible all -m ansible.builtin.user -a "name=automation password={{ 'devops' | password_hash('sha512') }}" -k -u mg0050 -K -b
ansible all -m ansible.posix.authorized_key -a "user=automation state=present key={{ lookup('file', '/Users/mg0050/.ssh/id_rsa.pub') }}" -u mg0050 -k -K  -b
ansible all -m community.general.sudoers -a "user=automation runas=root commands=ALL state=present name=automation" -u mg0050 -k -K -b
