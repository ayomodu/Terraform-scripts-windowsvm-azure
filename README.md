###############################################################################################################
THIS SCRIPT WAS WRITTEN IN Terraform v0.14.5

############################################################################################################################
THIS SCRIPT WILL PROVISION AS MANY WINDOWS VM'S AS SPECIFIED TO A VNET WITH AS MANY SUBNETS AS SPECIFIED.
SUBNET AND VM COUNT ARE TO BE SPECIFIED IN THE SCRIPT. IF YOU SPECIFY 2 SUBNETS AND 4 VMS IT WILL DEPLOY 2 VM'S PER SUBNET
IF YOU SPECIFY 2 SUBNETS AND 3 VMS IT WILL DEPLOY 2 VMS TO FIRST SUBNET AND 1 TO SECOND SUBNET AND SO ON...
SCRIPT WILL ALSO PROVISION A RESOURCE GROUP AS A PREREQUISITE FOR DEPLOYING AZURE RESOURCES.
SCRIPT WILL OUTPUT THE VM PUBLIC IPS  
###############################################################################################################

HOW TO USE:

module "${enter-name-of-module}" {
	source = "git@github.com:ayomodu/Terraform-scripts-windowsvm-azure.git"
	location    	 = "${enter-resource-location}"	
	rg-name	    	 = "${enter-resourcegroup-name}" #uses "new-rg" by default
	vnet-cidr   	 = "${enter-vnet-cidr}" #uses 10.0.0.0/16 by default (ensure to use a large enough prefix i.e /8 or /16 as each subnet is programmed to take a /24 prefix)
	subnet-count	 =  enter number # deploys 1 subnet by default
	sub-name    	 = "${enter-subnet-name}" #e.g "dev", "prod" or whatever custom name you prefer
	vm-name     	 = "${enter-vm-name}" #this variable takes a string value
	vm-count    	 =  enter number #deploys 1 VM by default
	vm-size	    	 = "${enter-vm-size}"
	username    	 = "${enter-vm-username}" #default is "new-user"
	password	 = "${enter-vm-password}"
	storage-acc-type = "${enter-storage-type}" #uses Standard_LRS by default
	image-sku   	 = "${enter-vm-sku}" #uses 2016-Datacenter by default
	vm-offer    	 = "${enter-vm-flavour}" #uses WindowsServer by default
	

}


output "pub-ip" {
    value = module.vm.VM_IPs
    #will output public ips for connecting to vms
}


