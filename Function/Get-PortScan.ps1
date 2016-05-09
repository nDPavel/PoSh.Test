# в случае единственного хоста указываем его адрес
$target = "oo-kach-05"
# в случае множественных целей можно подставить файл
#$target = get-content "hosts.txt"
# в случае прямого указания номеров портов пишем
$ports = @("21","22","23","80","139","443","445","1433","3389")
# в случае указания диапазона
$ports=(1..21) # проверять порты с 1 по 21
$ports+=(25..110) #пропускаем порты 22-24 и проверяем диапазон с 25 по 110
# выводим то что сканируем на экран
$ports

function check_port([string]$port_ip,[string]$c_port) {
        $timeout=3000
        $ErrorActionPreference = "SilentlyContinue"
        try {
            $tcpclient = new-Object system.Net.Sockets.TcpClient
            $iar = $tcpclient.BeginConnect($port_ip,$c_port,$null,$null)
            $wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false)
            if(!$wait) {
                $tcpclient.Close()
            Return $false
             } else {
                $error.Clear()
                $tcpclient.EndConnect($iar) | out-Null
                if(!$?){$failed = $true}
                    $tcpclient.Close()
                }
                 if($failed){return $FALSE}else{return $TRUE}
        }
    catch {
    return $FALSE
    }
}

function start_scan([string]$server) {
        $port_list = @()
        foreach($port in $ports) {
                $port_result = ""
                $port_result = check_port $server $port
                Write-Host "Server  $server. Port — $port Result : $port_result"
        if($port_result) {
           $port_list = $port_list + $port
        }
    }
    return $port_list
}

$scan = start_scan $target
Write-Host $scan



