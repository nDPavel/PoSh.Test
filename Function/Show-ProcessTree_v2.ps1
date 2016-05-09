Function Show-ProcessTree_v2
{
    Function Get-ProcessChildren($P,$Depth=1)
    {
        $procs | Where-Object {$_.ParentProcessId -eq $p.ProcessID -and $_.ParentProcessId -ne 0} | ForEach-Object {
            "{0}|--{1}" -f (" "*3*$Depth),$_.Name
            Get-ProcessChildren $_ (++$Depth)
            $Depth--
        }
    }
 
    #Фильтр для Where-Object
    $filter = {-not (Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue) -or $_.ParentProcessId -eq 0}
    #Получаем список процессов
    $procs = Get-WmiObject Win32_Process
    #Получаем список родительских процессов
    $top = $procs | Where-Object $filter | Sort-Object ProcessID
    foreach ($p in $top)
    {
        #Выводим имя родительского процесса
        $p.Name
        #Вызываем рекурсивную функцию,для получения дочерних процессов
        Get-ProcessChildren $p
    }
}


Show-ProcessTree_v2