variable "nom_group" {}
variable "nom_reseau" {}
variable "location" {}

#variable "adresse_space2" {
#	 type = "list"
#	 default = false
#}

variable "nom_sousreseau" {}
variable "ip_sousreseau1" {
	type = "string"
	default = false
}
variable "ip_sousreseau2" {
	type = "string"
	default = false
}
variable "nom_configuration" {
	default = false
}
variable "nom_osdisk" {
	default = false
}
variable  "nom_machine" {}
variable "username" {}
variable "motde_passe" {}
variable "taille_machine" {}
variable "caching_disk" {}
variable "option_disk" {}
variable "name_security" {}
variable  "priority" {}                  
variable  "direction"  {}           
variable  "access" {}                     
variable  "protocol" {}                  
variable "source_port_range" {}          
variable  "destination_port_range" {}     
variable  "source_address_prefix"  {
	type = "string"
}    
variable   "destination_address_prefix" {}
