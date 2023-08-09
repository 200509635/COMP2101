# Function to print welcome message
function welcome {
	write-output "Welcome to planet $env:computername Overlord $env:username"
	$now = get-date -format 'HH:MM tt on dddd'
	write-output "It is $now."
}

# Function to print hardware description
function system_hardware_description {
	write-output "System Hardware Description:"
    gwmi win32_computersystem | select Name, Manufacturer, Model, TotalPhysicalMemory, Description | format-list
}

# Function to print operating system information
function operating_system {
	write-output "Operating System:"
    gwmi win32_operatingsystem | select Name, Version | format-list
}

# Function to print processor description
function processor_description {
	write-output "Processor Description:"
    gwmi win32_processor | select Name, NumberOfCores, CurrectClockSpeed, MaxClockSpeed,@{
        n = "L1Cache";
        e = {switch ($_.L1CacheSize) {
                $null { $data = "data unavailable" }
                Default { $data = $_.L1CacheSize }
            };
            $data
        }
    },
    @{
        n = "L2Cache";
        e = {switch ($_.L2CacheSize) {
                $null { $data = "data unavailable" }
                Default { $data = $_.L2CacheSize }
            };
            $data
        }
    },
    @{
        n = "L3Cache";
        e = {
            switch ($_.L3CacheSize) {
                $null { $data = "data unavailable" }
                Default { $data = $_.L3CacheSize }
            };
            $data
        }
    } | format-list
}

# Function to print ram information
function ram_information {
	write-output "RAM Information:"
    $phymem = get-CimInstance win32_PhysicalMemory | select Description, manufacturer, banklabel, devicelocator, capacity
    $phymem | format-table

    $total = 0
	foreach ($pm in $phymem) {$total = $total + $pm.capacity}
	$total = $total / 1GB
    write-output "RAM : $total GB"
}

# Function to print physical disk information
function physical_disk_information {
	write-output "Physical Disk Information:"
    	$diskdrives = Get-CIMInstance CIM_diskdrive

	foreach ($disk in $diskdrives) {
		$partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
		foreach ($partition in $partitions) {
			$logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
			foreach ($logicaldisk in $logicaldisks) {
				new-object -typename psobject -property @{Manufacturer=$disk.Manufacturer
									  Model=$disk.Model
									  Location=$partition.deviceid
									  Drive=$logicaldisk.deviceid
									  "Size(GB)"=$logicaldisk.size / 1gb -as [int]
									  "FreeSpace(GB)"=$logicaldisk.FreeSpace / 1gb -as [int]
									  "FreeSpace(%)"=(($logicaldisk.FreeSpace / $logicaldisk.size) * 100) -as [int]
									  } | format-table -AutoSize
			}
		}
	}
}

# Function to print network adapter information
function network_adapter_information {
	write-output "Network Adapter Information:"
    	get-ciminstance win32_networkadapterconfiguration | where { $_.IPEnabled -eq $True } | 
    	format-table Description, Index, IPAddress, IPSubnet, DNSDomain, DNSServerSearchOrder -AutoSize
}

# Function to print video information
function video_information {
	write-output "Video Controller Information:"
    	get-CimInstance win32_videocontroller | select description, caption, currenthorizontalresolution,     currentverticalresolution

    	$h = $obj.currenthorizontalresolution
    	$v = $obj.currentverticalresolution
    	$resolution = "$h x $v"
    	$resolution
}
