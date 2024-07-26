***********************************************************************************
***************************    Estimación modelo tesis  *********************************
***************************        20-Octubre-2012      **********************************
***************************      by: Juan Santos O.   ***********************************
***************************        Unicartagena      *************************************
***********************************************************************************

*--------------------------------------------------------*
* ESTABLECIENDO DIRECTORIO DE TRABAJO *
*--------------------------------------------------------*
clear all
set more off
set mem 200m
{
global C "E:/"
global PC "${C}Dropbox\Trabajo de Grado\Procesamiento de informacion/"
global B "${PC}bases/"
global B2 "${C}Datos/ENDS 2010/"
global G "${PC}graficas/"
global L "${PC}log/"
global T "${PC}Tablas/"
global PUB "${C}Dropbox\public/"
cd "$PC"
}
*

**************************************************************************
*********** GRÁFICA PIRAMIDE POBLACIONAL***************************
**************************************************************************

use "${B}poblacion edades quinquenales 1985-2020", clear

replace grupo_edad="05-9" if grupo_edad=="5-9"

drop if grupo_edad=="Total"

keep if codepto==8 | codepto==13 | codepto==20 | codepto==23 | codepto==44 | codepto==47 | codepto==70 | codepto==88

egen grupo=group(grupo_edad), label

replace grupo_edad="5-9" if grupo_edad=="05-9"

collapse (sum) hombres_2010 mujeres_2010, by(grupo grupo_edad)

replace hombres_2010 =-hombres_2010 /1000
replace mujeres_2010 =mujeres_2010 /1000


tw bar hombres_2010 grupo, horizontal xvarlab(Hombres) ||  bar mujeres_2010 grupo, horizontal xvarlab(Mujeres) || , ylabel(1(1)17, angle(horizontal) valuelabel labsize(*.7) nogrid) ///
xtitle(" " "Población en miles") ytitle(" ") xlabel(-500 "500" -400 "400" -300 "300" -200 "200" -100 "100" 0 "0" 100 "100" 200 "200" 300 "300" 400 "400" 500 "500") ///
graphregion(fcolor(white)) legend(label(1 "Hombres") label(2 "Mujeres")) name("piramide_poblacion_caribe", replace) saving("${G}piramide_poblacion_caribe", replace)

graph export "${G}piramide_poblacion_caribe.png", replace name ("piramide_poblacion_caribe") width(1200) height(800)

**************************************************************************
*********** GRÁFICA PIB PER CAPITA*************************************
**************************************************************************

use "${B}pib_pc_caribe", clear

replace pib_pc_cons=pib_pc_cons/1000000
egen dep=group(depto), label

tw bar pib_pc_cons dep, xlabel(1(1)9, angle(40) valuelabel )  ylabel(4(1)10, nogrid) ///
ytitle("Millones de pesos" " ") xtitle(" ") graphregion(fcolor(white)) fcolor(red) lcolor(black) lwidth(medium) barwidth(0.95)  ///
name("pib_pc_caribe", replace) saving("pib_pc_caribe", replace)

graph export "${G}pib_pc_caribe.png", replace name ("pib_pc_caribe") width(1200) height(800)

**************************************************************************
*********** GRÁFICA MALA SALUD vs TMI********************************
**************************************************************************

use "${B}salud_mala_tmi", clear

label var tmi "Tasa de Mortalidad Infantil"
label var malo "% de poblacion con smal estado de salud"

scatter tmi malo , graphregion(fcolor("white")) ylabel(, nogrid)  mlabel(departamento) mlabsize(3.5) xtitle("Poblacion con mal estado de salud (%)" " ") ///
ytitle(" " "Tasa de Mortalidad Infantil" "(Por mil nacidos vivos)") || lfit tmi malo, legend(off) name("salud_mala_tmi", replace) saving("salud_mala_tmi", replace)

graph export "${G}salud_mala_tmi.png", replace name ("salud_mala_tmi") width(1200) height(800)

**************************************************************************
*********** GRÁFICA MALA SALUD vs POBREZA***************************
**************************************************************************

use "${B}salud_mala_tmi", clear

label var tmi "% de población bajo línea de pobreza"
label var malo "% de poblacion con mal estado de salud"

scatter pobreza malo , graphregion(fcolor("white")) ylabel(, nogrid)  mlabel(departamento) mlabsize(3.5) xtitle("Poblacion con mal estado de salud (%)" " ") ///
xlabel(25(5)40) ytitle(" " "Población bajo línea de pobreza (%)") || lfit pobreza malo, legend(off) name("pobreza_tmi", replace) saving("pobreza_tmi", replace)

graph export "${G}pobreza_tmi.png", replace name ("pobreza_tmi") width(1200) height(800)




