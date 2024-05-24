pipelineJob('deploy-template-and-vm') {
    parameters {
        choiceParam('opentofu_action', ['apply', 'destroy'])
        choiceParam('target', ['jenkins-1', 'jenkins-2', 'debian_template', 'samba-1', 'samba-2'])
        booleanParam('ansible_needed',true)
        choiceParam('playbook', ['jenkins', 'samba'])
    }
    definition {
        cps {
            script(
                '''
                pipeline {
                    agent { label 'agent-opentofu-ansible' }
                    options {
                        ansiColor('xterm')
                    }
                    stages {
                        stage('Plan and Destroy') {
                            // agent { label 'agent-opentofu' }
                            when {
                                expression { params.opentofu_action == 'destroy' }
                            }
                            steps {
                                cleanWs()
                                sh \'''
                                    cd /home/jenkins/opentofu-proxmox/
                                    #tofu workspace select -or-create=true ${target}
                                    #tofu plan -out=tfplan/${target}.tfplan -var-file=./variables/${target}.tfvars -destroy
                                    tofu plan -out=terraform.tfplan -destroy
                                    tofu apply -auto-approve terraform.tfplan
                                    #tofu workspace select default
                                    #tofu workspace delete ${target}
                                \'''
                            }
                        }
                        stage('Init, Plan and Apply - VM') {
                            // agent { label 'agent-opentofu' }
                            when {
                                expression { params.opentofu_action == 'apply'}
                            }
                            steps {
                                sh \'''
                                    cd /home/jenkins/opentofu-proxmox/
                                    tofu init -upgrade
                                    #tofu workspace select -or-create=true ${target}
                                    tofu fmt
                                    tofu validate
                                    #tofu plan -out=tfplan/${target}.tfplan -var-file=./variables/${target}.tfvars
                                    tofu plan -out=terraform.tfplan
                                    tofu apply -auto-approve terraform.tfplan
                                \'''
                            }
                        }
                        stage('Ansible') {
                            // agent { label 'agent-ansible' }
                            when {
                                expression { params.opentofu_action == 'apply' && params.ansible_needed }
                            }
                            steps {
                                sh \'''
                                    echo "Waiting for VM to be booted"
                                    #for i in {1..10}; do
                                    #    if ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/jenkins/sshkeys/jenkins_agent_ansible_key jenkins@192.168.0.61 exit; then
                                    #        i=11;
                                    #    else
                                    #        sleep 1
                                    #    fi
                                    #done
                                    sleep 5
                                    #export ANSIBLE_CALLBACKS_ENABLED="profile_tasks"
                                    #export ANSIBLE_SSH_ARGS="-C -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
                                    #cd /home/jenkins/ansible-playbooks
                                    #export ANSIBLE_HOST_KEY_CHECKING=False
                                    #ansible-playbook -i inventory.yml site.yml
                                \'''
                                ansiblePlaybook colorized: true, inventory: '/home/jenkins/ansible-playbooks/inventory.yml', playbook: '/home/jenkins/ansible-playbooks/${playbook}.yml', extraVars: [host: '${target}']
                            }
                        }
                    }
                }
                '''.stripIndent()
            )
            sandbox()     
        }
    }
}