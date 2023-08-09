Param ([Parameter (Mandatory=$false)][switch]$System,
       [Parameter (Mandatory=$false)][switch]$Disks,
       [Parameter (Mandatory=$false)][switch]$Network )


if($System) {
	system_hardware_description
	operating_system 
	processor_description 
	ram_information 
	video_information
}
elseif($Disks) {
	physical_disk_information
}
elseif($Network) {
	network_adapter_information
}
else {
	system_hardware_description
	operating_system 
	processor_description 
	ram_information 
	physical_disk_information 
	network_adapter_information 
	video_information
}