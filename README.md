###########################Jnekinsfile########################
terraform apply
###########################jenkinsfile2#######################
terrafrom destroy


Configuration jenkins :

installer le plugin terraform

ssh key pour le scm git

coder les credentials en base64 et les integrer dans notre pipeline comme variable "SVC_ACCOUNT_KEY = credentials('terraform-auth')"
