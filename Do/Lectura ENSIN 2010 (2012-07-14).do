***********************************************************************************
***************************     Lectura ENSIN 2010    **********************************
***************************      by: Juan Santos O.   ***********************************
***************************        Unicartagena      *************************************
***********************************************************************************

*--------------------------------------------------------*
* ESTABLECIENDO DIRECTORIO DE TRABAJO *
*--------------------------------------------------------*

{
* PC Escritorio
	* Stata 11
if "`c(sysdir_stata)'"=="D:\Programas\computador\Stata11/" {
global C "D:\"
}
	* Stata 12
if "`c(sysdir_stata)'"=="D:\Programas\computador\Stata 12_SE/" {
global C "D:\"
}

* PC portatil
if "`c(sysdir_stata)'"=="C:\Users\COMPAQMINI\Documents\Stata11/"{
global C "C:\Users\COMPAQMINI\Documents\\"
}
*
* PC GIES
if "`c(sysdir_stata)'"=="E:\Stata11/"{
global C "E:\"
}
if "`c(sysdir_stata)'"=="E:\Stata12_WinX86_x64/"{
global C "E:\"
}
* Otro computador
else if{
disp(`"Si desea descargar la base pinche {stata "use http://dl.dropbox.com/u/10840442/ends_2010.dta, clear": aqui}"')
}
*

global PC "${C}Dropbox\Trabajo de Grado\Procesamiento de informacion/"
global B "${PC}bases/"
global B2 "${C}Datos/ENDS 2010/"
global B3 "${C}Datos\ENSIN\Bases/"
global G "${PC}graficas/"
global L "${PC}log/"
global T "${PC}Tablas/"
global PUB "${C}Dropbox\public/"
cd "$PC"
}

*---------------------------------------------------------*
*      INTRODUCIENDO DATOS           *
*---------------------------------------------------------*

use "${B3}ACTFISICA", clear

*  clase_imc
*Cardio_Vascular
* af46c   Actualmente hace actividad física
 
use "${B3}Antropometria", clear
use "${B3}bioquimica", clear
use "${B3}consumo", clear
*co33  un salero en la mesa
*co34a toma desayuno
use "${B3}segaliment ultima", clear
* punt_dos2005 grado de seguridad alimentaria
*punt_re2010_1 clasificacion seg alimentaria
use "${B3}tvpcorp", clear
