$class = "Win32_SoundDevice","win32_keyboard"

$class | % {gwmi $_ | ? description -match ‘usb’} | ft description, PNPDeviceID -A –Wr