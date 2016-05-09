 <#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <
   Функция для парсинга строк.
   Выводит сивволы до первного указанного символа в строке например ';' 
   может работать с дополнительным сиволом в строке
   >
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>


function StrFirstSimb
    {
    param ([string]$PSGF, [string]$Poz)
    $Result = ''
    #перебираем все строки если передан файл 
    foreach ($Key in $PSGF)
	    {
	        $Val = $Key.ToString().Split(';')
	        $test = $val[$Poz]#Выводим диапазо найденный разграничеий
	        #$Val = $test.ToString().Split(',')#дополнительные символы для разделения
	        #$test = $Val[0]
	        $Result = $Result + "$test`r`n"
	    }

    return $Result
    }
StrFirstSimb -Poz  -PSGF '90000;"ООО ""Телеком Евразия""";Краснодарский край'