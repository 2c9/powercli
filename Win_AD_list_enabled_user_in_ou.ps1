
# Run as Admin
Get-ADUser -Filter 'enabled -eq $true' -Properties Description,userAccountControl -SearchBase "OU=SUBOU,OU=MYOU,DC=OUIIT,DC=LOCAL" 
