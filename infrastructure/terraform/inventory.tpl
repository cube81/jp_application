[aws]
${ansible_ip}

[aws:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=../jp-max.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
