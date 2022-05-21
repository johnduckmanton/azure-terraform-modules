# Retrieve the forest to add to. You can retrieve via a Variable and use an if/else if more than one forest is available.
$domain="zurich.com"
# User for domain join
$user_account = "svc-ccoe-iaas-build"
$password = ConvertTo-SecureString 'TBA' -AsPlainText -Force
# Use var password as a credential
$credential = New-Object System.Management.Automation.PSCredential($user_account,$password)
# Add to domain with new name
Add-Computer -DomainName $domain -Credential $credential
# Reboot the computer to accept the new domain name and computer name.
Restart-Computer -Force