****************************************
*** Tablas Capítulo 3 trabajo de grado***
********Juan Santos Ochoa**************
**********Unicartagena*****************
**********2013-08-10*******************
****************************************

clear all
set more off
set mem 200m

*
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
disp(`"Si desea descargar la base pinche {stata "use http://dl.dropbox.com/u/10840442/ends_2010.dta, clear": aqui}"')
}
*

capture log close
log using "${L}tablas_nacional.smcl", replace

use "${B}ends_2010", clear

keep if edad>=18
* Salud por regiones

set more off
estpost tab region salud [iw=pon]
mat region_salud=e(rowpct)'

esttab mat(region_salud, fmt(%5.1f)) using "${T}col_region_salud", unstack replace plain csv
stcmd "${T}col_region_salud.csv" "${T}col_region_salud.xlsx" /y 
erase "${T}col_region_salud.csv"

* Tabla 4 Salud Vs Grupo de edad

set more off
estpost tab grupo_edad salud [iw=pon]
mat edad_salud=e(rowpct)'

esttab mat(edad_salud, fmt(%5.1f)) using "${T}col_edad_salud", unstack replace plain csv
stcmd "${T}col_edad_salud.csv" "${T}col_edad_salud.xlsx" /y 
erase "${T}col_edad_salud.csv"

* Tabla 5 Salud Vs Género

set more off
estpost tab sexo salud [iw=pon]
mat sexo_salud=e(rowpct)'

esttab mat(sexo_salud, fmt(%5.1f)) using "${T}col_sexo_salud", unstack replace plain csv
*
forvalues x=1/6{
estpost tab sexo salud [iw=pon] if region==`x'
mat sexo_salud_`x'=e(rowpct)'
esttab mat(sexo_salud_`x', fmt(%5.1f)) using "${T}col_sexo_salud", unstack append plain csv
}
*
stcmd "${T}col_sexo_salud.csv" "${T}col_sexo_salud.xlsx" /y 
erase "${T}col_sexo_salud.csv"
*

* Tabla 6 Salud Vs Educación

set more off
estpost tab nivel_educativo salud [iw=pon]
mat nivel_educativo_salud=e(rowpct)'

esttab mat(nivel_educativo_salud, fmt(%5.1f)) using "${T}col_nivel_educativo_salud", unstack replace plain csv
*
foreach x in 0 1{
estpost tab nivel_educativo salud [iw=pon] if sexo==`x'
mat nivel_educativo_salud_`x'=e(rowpct)'
esttab mat(nivel_educativo_salud_`x', fmt(%5.1f)) using "${T}col_nivel_educativo_salud", unstack append plain csv
}
*
stcmd "${T}col_nivel_educativo_salud.csv" "${T}col_nivel_educativo_salud.xlsx" /y 
erase "${T}col_nivel_educativo_salud.csv"

* Tabla 7 Salud Vs Nivel de riqueza y área de residencia

set more off
estpost tab riqueza salud [iw=pon]
mat riqueza_salud=e(rowpct)'

esttab mat(riqueza_salud, fmt(%5.1f)) using "${T}col_riqueza_salud", unstack replace plain csv
*
foreach x in 1 2{
estpost tab riqueza salud [iw=pon] if area==`x'
mat riqueza_salud_`x'=e(rowpct)'
esttab mat(riqueza_salud_`x', fmt(%5.1f)) using "${T}col_riqueza_salud", unstack append plain csv
}
*
stcmd "${T}col_riqueza_salud.csv" "${T}col_riqueza_salud.xlsx" /y 
erase "${T}col_riqueza_salud.csv"

** Gráfica PIB, GINI, Salud
set more off
estpost tab depto salud [iw=pon]
mat col_depto_salud=e(rowpct)'

esttab mat(col_depto_salud, fmt(%5.1f)) using "${T}col_depto_salud", unstack replace plain csv

insheet using "${B}depto_salud.csv", clear
sort cod
merge 1:1 cod using "${B}gini_ipm", keep(3) nogen
replace ipm=ipm*100
*Pobreza Alta,  Gini Alto
graph bar m b mb if  ripm>12 & rgini>12, over(dep, label(labsize(*.8) angle(30))) stack t2title("Alto IPM/Alto Gini") bar(3, fcolor(green*0.7) lcolor(black)) legend(rows(1) label(1 "Malo")  label(2 "Bueno") label(3 "Muy Bueno")) bar(2, fcolor(yellow) lcolor(black)) bar(1, fcolor(red*.8) lcolor(black)) graphregion(fcolor(white)) name(alto_alto, replace) 
* Pobreza Baja, Gini Alto
graph bar m b mb if  ripm<=12 & rgini>12, over(dep, label(labsize(*.8) angle(30))) stack  t2title("Bajo IPM/Alto Gini") bar(3, fcolor(green*0.7) lcolor(black))  legend(rows(1)) bar(2, fcolor(yellow) lcolor(black)) bar(1, fcolor(red*.8) lcolor(black)) graphregion(fcolor(white)) name(bajo_alto, replace)
* Pobreza Alta, Gini Bajo
graph bar m b mb if  ripm>12 & rgini<=12, over(dep, label(labsize(*.8) angle(30))) stack t2title("Alto IPM/Bajo Gini")  legend(rows(1)) bar(3, fcolor(green*0.7) lcolor(black)) bar(2, fcolor(yellow) lcolor(black)) bar(1, fcolor(red*.8) lcolor(black)) graphregion(fcolor(white)) name(alto_bajo, replace)
* Pobreza Baja, Gini Bajo
graph bar m b mb if  ripm<=12 & rgini<=12, over(dep, label(labsize(*.8) angle(30))) stack t2title("Bajo IPM/Bajo Gini") bar(3, fcolor(green*0.7) lcolor(black))  legend(label(1 "Malo") rows(1))  bar(2, fcolor(yellow) lcolor(black)) bar(1, fcolor(red*.8) lcolor(black)) graphregion(fcolor(white)) name(bajo_bajo, replace)

grc1leg alto_bajo alto_alto bajo_bajo bajo_alto, legendfrom(alto_alto) rows(2) graphregion(fcolor(white)) name("gini_ipm", replace) saving("${G}gini_ipm", replace)
 graph export "${G}gini_ipm.png", replace name ("gini_ipm") width(1200) height(800)

 ** Gráfica PMI, Mala salud
 insheet using "${B}depto_salud.csv", clear
merge 1:1 cod using "${B}ipm",  nogen
replace ipm=ipm*100
gen dep2=substr(depto_2,1,3))

 scatter m ipm,  mlabel(dep2) || lfit m ipm, ytitle("Porcentaje mal estado de salud" " ") xtitle(" " "Indice de Pobreza Multidimensional") ylabel(, nogrid) graphregion(fcolor(white)) legend(off) name(ipm_mala_salud, replace)  saving("${G}ipm_mala_salud", replace)
 graph export "${G}ipm_mala_salud.png", replace name ("ipm_mala_salud") width(1200) height(800)


