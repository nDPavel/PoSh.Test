function findmac ($mac) {
$x=96 #подсети
$y=1..254 #компы
foreach ($lan in $x) { #перебираем подсети
$y | foreach { #перебираем компы
$comp="10.255.$lan.$_"
$ping=Get-WmiObject -Query "select * from win32_pingstatus where (address='$comp')"
if ($ping.statuscode -eq 0) { #будем выполнять поиск мака только у пингующегося ip 
echo $comp #показывает над каким компом сейчас думает скрипт
if ((nbtstat -A $comp) -match $mac) { #условие - если строка с маком из Nbtstat совпала с искомым маком,
echo "$comp is $mac" # показываем что мак найден
break #завершаем выполнение
}}
}}
}




findmac -mac "90-2B-34-C8-87-1F"