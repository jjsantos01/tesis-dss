**********************************************************
****** TABLAS CAPÍTULO 1******************************
**********************************************************


*--------------------------------------------------------*
* ESTABLECIENDO DIRECTORIO DE TRABAJO *
*--------------------------------------------------------*

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

use "${B}ends_2010", clear

capture log close

 log using "${L}Tablas capítulo 1", replace
 
 keep if edad>=18


* Tabla 3 Salud vs Departamento

set more off
estpost tab depto salud [iw=pon] if caribe==1
mat depto_salud=e(rowpct)'

esttab mat(depto_salud, fmt(%5.1f)) using "${T}depto_salud", unstack replace plain csv
stcmd "${T}depto_salud.csv" "${T}depto_salud.xlsx" /y 
erase "${T}depto_salud.csv"

* Tabla 4 Salud Vs Grupo de edad

set more off
estpost tab grupo_edad salud [iw=pon] if caribe==1
mat edad_salud=e(rowpct)'

esttab mat(edad_salud, fmt(%5.1f)) using "${T}edad_salud", unstack replace plain csv
stcmd "${T}edad_salud.csv" "${T}edad_salud.xlsx" /y 
erase "${T}edad_salud.csv"

* Tabla 5 Salud Vs Género

gen malo=(salud==3)
gen bueno=(salud==2)
gen mbueno=(salud==1)

set more off
estpost tab sexo salud [iw=pon] if caribe==1
mat sexo_salud=e(rowpct)'

ttest malo [iw=pon] if caribe==1, by(sexo)
scalar M_caribe=r(p)
ttest bueno if caribe==1, by(sexo)
scalar B_caribe=r(p)
ttest mbueno if caribe==1, by(sexo)
scalar MB_caribe=r(p)
mat pval=(M_caribe, B_caribe, MB_caribe)

esttab mat(sexo_salud, fmt(%5.1f)) using "${T}sexo_salud", unstack replace plain csv
*
foreach x in 8 13 20 23 44 47 70 88{
estpost tab sexo salud [iw=pon] if depto==`x'
mat sexo_salud_`x'=e(rowpct)'
esttab mat(sexo_salud_`x', fmt(%5.1f)) using "${T}sexo_salud", unstack append plain csv

ttest malo if depto==`x', by(sexo)
scalar M_`x'=r(p)
ttest bueno if depto==`x', by(sexo)
scalar B_`x'=r(p)
ttest mbueno if depto==`x', by(sexo)
scalar MB_`x'=r(p)

mat pval=(pval\M_`x', B_`x', MB_`x')
}
*
stcmd "${T}sexo_salud.csv" "${T}sexo_salud.xlsx" /y 
erase "${T}sexo_salud.csv"
*

* Tabla 6 Salud Vs Educación

set more off
estpost tab nivel_educativo salud [iw=pon] if caribe==1
mat nivel_educativo_salud=e(rowpct)'

esttab mat(nivel_educativo_salud, fmt(%5.1f)) using "${T}nivel_educativo_salud", unstack replace plain csv
*
foreach x in 0 1{
estpost tab nivel_educativo salud [iw=pon] if sexo==`x' & caribe==1
mat nivel_educativo_salud_`x'=e(rowpct)'
esttab mat(nivel_educativo_salud_`x', fmt(%5.1f)) using "${T}nivel_educativo_salud", unstack append plain csv
}
*
stcmd "${T}nivel_educativo_salud.csv" "${T}nivel_educativo_salud.xlsx" /y 
erase "${T}nivel_educativo_salud.csv"

* Tabla 7 Salud Vs Nivel de riqueza y área de residencia

set more off
estpost tab riqueza salud [iw=pon] if caribe==1
mat riqueza_salud=e(rowpct)'

esttab mat(riqueza_salud, fmt(%5.1f)) using "${T}riqueza_salud", unstack replace plain csv
*
foreach x in 1 2{
estpost tab riqueza salud [iw=pon] if area==`x' & caribe==1
mat riqueza_salud_`x'=e(rowpct)'
esttab mat(riqueza_salud_`x', fmt(%5.1f)) using "${T}riqueza_salud", unstack append plain csv
}
*
stcmd "${T}riqueza_salud.csv" "${T}riqueza_salud.xlsx" /y 
erase "${T}riqueza_salud.csv"

* Tabla 8 Salud Vs  Ocupación

set more off
estpost tab ocupado_cat salud [iw=pon] if caribe==1
mat ocupado_cat_salud=e(rowpct)'

esttab mat(ocupado_cat_salud, fmt(%5.1f)) using "${T}ocupado_cat_salud", unstack replace plain csv
stcmd "${T}ocupado_cat_salud.csv" "${T}ocupado_cat_salud.xlsx" /y 
erase "${T}ocupado_cat_salud.csv"

* Tabla 9 Salud Vs  Pertenencia étnica y sexo

set more off
estpost tab etnia salud [iw=pon] if caribe==1
mat etnia_salud=e(rowpct)'

esttab mat(etnia_salud, fmt(%5.1f)) using "${T}etnia_salud", unstack replace plain csv
*
foreach x in 0 1{
estpost tab etnia salud [iw=pon] if sexo==`x' & caribe==1
mat etnia_salud_`x'=e(rowpct)'
esttab mat(etnia_salud_`x', fmt(%5.1f)) using "${T}etnia_salud", unstack append plain csv
}
*
stcmd "${T}etnia_salud.csv" "${T}etnia_salud.xlsx" /y 
erase "${T}etnia_salud.csv"


capture log close
disp(`"Si desea ver el Log pinche {stata `"view "${L}Tablas capítulo 1.smcl""': aqui}"')


