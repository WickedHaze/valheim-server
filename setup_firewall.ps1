netsh advfirewall firewall delete rule name='Valheim UDP 2456' 2>$null
netsh advfirewall firewall delete rule name='Valheim UDP 2457' 2>$null
netsh advfirewall firewall delete rule name='Valheim TCP 2458' 2>$null

netsh advfirewall firewall add rule name='Valheim UDP 2456'   dir=in action=allow protocol=UDP localport=2456 profile=any
netsh advfirewall firewall add rule name='Valheim UDP 2457'   dir=in action=allow protocol=UDP localport=2457 profile=any
netsh advfirewall firewall add rule name='Valheim TCP 2458'   dir=in action=allow protocol=TCP localport=2458 profile=any

Write-Output 'Valheim firewall rules applied.'
