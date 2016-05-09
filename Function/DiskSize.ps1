Function DiscSize($ip){
Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -Computer $ip | 
	Select SystemName,DeviceID,@{Name="size(GB)"; 
									Expression={"{0:N1}" -f($_.size/1gb)}
								},@{Name="freespace(GB)";
								Expression={"{0:N1}" -f($_.freespace/1gb)}} | 
	Format-Table -AutoSize
	
	}
DiscSize -ip 10.255.110.71






	
	