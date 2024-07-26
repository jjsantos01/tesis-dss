clear all
set more off
set mem 200m

*
{
global C "E:/"
global PC "${C}Dropbox\otros\Trabajo de Grado\Procesamiento de informacion/"
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
log using "${L}regresion_nacional.smcl", replace

use "${B}regresion_colombia", clear

global indep "edad sexo tamaño_hogar estado_civil etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso urbano"
global indep2 "edad sexo tamaño_hogar etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso"


***Modelo Colombia
set more off
quietly: eststo modelocol: svy: mlogit salud ${indep}, nolog rrr

* Exportando resultados
esttab modelocol using "${T}col_regresion.csv",  replace cells(`"b(fmt(3) label("Coef.")  ) p(fmt(3) label("p-valor")) & _star ci(fmt(3)) "')  starlevels(** 0.05) drop("o.*" ) unstack  plain ///
mlabels("ModeloNacional", span) eqlabels("Muy Bueno" "Malo") eform

stcmd "${T}col_regresion.csv" "${T}col_regresion.xlsx" /y 
erase "${T}col_regresion.csv"

esttab modelocol using "${T}col_ci.csv" ,  replace cells(`"b(fmt(3) label("Coef.")  ) ci(fmt(%4.3f))"')  starlevels(* 0.10 ** 0.05 *** 0.01) drop("o.*" ) unstack  plain eform

* Pruebas de Ajuste

set more off
quietly: mlogit salud ${indep} [pw=pon], nolog rrr
estadd fitstat, replace
mat bondadcol=e(ll_0)\e(ll)\e(dev)\e(lrx2_p)\e(r2_mf)\e(r2_mfadj)\e(r2_ml)\e(r2_cu)\e(aic0)\e(statabic)
mat rownames bondadcol="LL0" "LL Full" "Deviance" "LL p" "R2MF" "R2MFAJ" "R2ML" "R2CU" "AIC" "BIC"	
esttab matrix(bondadcol, fmt(%10.3f)) using "${T}bondadcol.csv", plain replace
stcmd "${T}bondadcol.csv" "${T}bondadcol.xlsx" /y 
erase "${T}bondadcol.csv"


 ** Probabilidades predichas
 use "${B}regresion_colombia", clear

global indep "edad sexo tamaño_hogar estado_civil etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso urbano"
global indep2 "edad sexo tamaño_hogar etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso"

 quietly: svy: mlogit salud ${indep}, nolog rrr
 predict MB B M
label var MB "Muy Bueno"
label var B "Bueno"
label var M "Malo"

* Efectos marginales promedios
set more off
forvalues i=1/3{
margins, dydx(*) predict(outcome(`i'))
mat EP`i'=r(table)'
mat EP`i'=100*EP`i'[1...,1],EP`i'[1...,4]
}
mat EP=EP1,EP2,EP3
mat colnames EP="Muy Bueno" "P" "Bueno" "P" "Malo" "P"

esttab matrix(EP, fmt(%5.3f)) using "${T}col_efectos_promedio.csv", plain replace
stcmd "${T}col_efectos_promedio.csv" "${T}col_efectos_promedio.xlsx" /y 
erase "${T}col_efectos_promedio.csv"



* Grafica CI

clear all
insheet using "${T}col_ci.csv", clear
drop in 1/3
drop if v1=="N" | v1=="_cons"
	*Muy bueno

gen cont=_n+10
tostring cont, replace
gen var=cont+"_"+v1
encode var, gen(variable)
destring v2, gen(rrr_mb)
gen ci_up_mb=substr(v3,1,5)
gen ci_low_mb=substr(v3,7,11)
destring ci_up ci_low, replace
	* malo

destring v4, gen(rrr_m)
gen ci_up_m=substr(v5,1,5)
gen ci_low_m=substr(v5,7,11)
destring ci_up_m ci_low_m, replace
 
 
 tw rcap ci_up_mb ci_low_mb variable, horizontal ylabel(1 "Edad" 2 "Sexo" 3 "Tamaño hogar" 4 "Estado civil" 5 "Etnia" 6 "Ocupado" 7 "Educacióin" 8 "Quintil 2" 9 "Quintil 3" 10 "Quintil 4" 11 "Quintil 5" 12 "Reg. Contributivo" 13 "Reg. Subsidiado" 14 "Reg. Especial" 15 "Obesidad" 16"Bajo peso" 17 "Urbano", labsize(small) angle(0)) yscale(reverse) graphregion(fcolor(white)) ///
 ytitle("") xtitle(" " "Riesgo relativo") legend(label(1 "Intervalo de confianza") label(2 "RRR") size(*.7)) xline(1, lpattern("-") lwidth(*.5)) || scatter  variable rrr_mb, mlabel(rrr_mb) mlabpos(6) mlabgap(0.05) mlabsize(*0.8) title("Muy bueno" " ", size(*.7)) name("col_ci_mb", replace) saving("${G}col_ci_mb", replace)

  tw rcap ci_up_m ci_low_m variable, horizontal ylabel(1 "Edad" 2 "Sexo" 3 "Tamaño hogar" 4 "Estado civil" 5 "Etnia" 6 "Ocupado" 7 "Educacióin" 8 "Quintil 2" 9 "Quintil 3" 10 "Quintil 4" 11 "Quintil 5" 12 "Reg. Contributivo" 13 "Reg. Subsidiado" 14 "Reg. Especial" 15 "Obesidad" 16"Bajo peso" 17 "Urbano", labsize(small) angle(0)) yscale(reverse) graphregion(fcolor(white)) ///
 ytitle("") xtitle(" " "Riesgo relativo") legend(label(1 "Intervalo de confianza") label(2 "RRR") size(*.7)) xline(1, lpattern("-") lwidth(*.5)) || scatter  variable rrr_m, mlabel(rrr_m) mlabpos(6) mlabgap(0.05) mlabsize(*0.8) title("Malo" " ", size(*.7)) name("col_ci_m", replace) saving("${G}col_ci_m", replace)

grc1leg "${G}col_ci_mb" "${G}col_ci_m", graphregion(fcolor(white)) legendfrom("${G}col_ci_mb") name(col_ci, replace) saving("${G}col_ci", replace)
 graph export "${G}col_ci.png", replace name ("col_ci") width(1200) height(800)
 graph export "${G}col_ci.eps", replace name ("col_ci") 

 *** Probabilidades condicionales
 
 
 set more off
 use "${B}regresion_colombia", clear
 quietly: svy: mlogit salud ${indep}, nolog rrr

*** Edad

	quietly:  prgen edad, gen(edad_) ncases(20)
	*sexo
	quietly:  prgen edad, x(sexo=1) gen(edad_sex1_) ncases(20)
	quietly:  prgen edad, x(sexo=0) gen(edad_sex0_) ncases(20)
	* Riqueza
	quietly:  prgen edad, x(riqueza_2=0 riqueza_3=0 riqueza_4=0 riqueza_5=0) gen(edad_riq1_) ncases(20)
	quietly:  prgen edad, x(riqueza_2=1 riqueza_3=0 riqueza_4=0 riqueza_5=0) gen(edad_riq2_) ncases(20)
	quietly:  prgen edad, x(riqueza_2=0 riqueza_3=1 riqueza_4=0 riqueza_5=0) gen(edad_riq3_) ncases(20)
	quietly:  prgen edad, x(riqueza_2=0 riqueza_3=0 riqueza_4=1 riqueza_5=0) gen(edad_riq4_) ncases(20)
	quietly:  prgen edad, x(riqueza_2=0 riqueza_3=0 riqueza_4=0 riqueza_5=1) gen(edad_riq5_) ncases(20)
	* Etnia
	quietly:  prgen edad, x(etnia=1) gen(edad_etn_) ncases(20)
	quietly:  prgen edad, x(etnia=0) gen(edad_netn_) ncases(20)
	*EPS
	quietly:  prgen edad, x(eps_cont=0  eps_sub=0 eps_esp=0) gen(edad_epsno_) ncases(20)
	quietly:  prgen edad, x(eps_cont=1  eps_sub=0 eps_esp=0 ) gen(edad_epsc_) ncases(20)
	quietly:  prgen edad, x(eps_cont=0  eps_sub=1 eps_esp=0) gen(edad_epss_) ncases(20)
	quietly:  prgen edad, x(eps_cont=0  eps_sub=0 eps_esp=1) gen(edad_epse_) ncases(20)
	
	* Labels
	
	label var edad_p1 "Muy Bueno"
	label var edad_p2 "Bueno"
	label var edad_p3 "Malo"
	label var edad_sex1_p3 "Hombres"
	label var edad_sex0_p3 "Mujeres"
	label var edad_riq1_p3 "Quintil 1"
	label var edad_riq2_p3 "Quintil 2"
	label var edad_riq3_p3 "Quintil 3"
	label var edad_riq4_p3 "Quintil 4"
	label var edad_riq5_p3 "Quintil 5"
	label var edad_etn_p3 "Étnicos"
	label var edad_netn_p3 "No étnicos"
	label var edad_epsno_p3  "Ninguno"
	label var edad_epsc_p3  "Contributivo"
	label var edad_epss_p3 "Subsidiado"
	label var edad_epse_p3 "Especial"
	
	outsheet edad_x edad_p1 edad_p2 *_p3 in 1/20 using "${T}col_prgen_edad.csv", comma replace

	
	*************
	*GRAFICAS**
	*************
	
	* Todos los estados de salud
	quietly: scatter edad_p1 edad_p2 edad_p3 edad_x, connect(l l l)  msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).7, nogrid) xtitle("Edad") xlabel(20(5)65)  name(col_pr_edad, replace) saving("${G]col_pr_edad", replace) 
	graph export "${G}col_pr_edad.png", replace name("col_pr_edad") width(1200) height(800)

	*  Hombre vs Mujer vs General | salud=Malo
	quietly: scatter edad_sex1_p3 edad_sex0_p3 edad_x, connect(l l l) msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).5, nogrid) xtitle("Edad") xlabel(20(5)65) subtitle("Sexo") name(col_pr_edad_sexo, replace)
	*  Riqueza | salud=Malo
	quietly: scatter edad_riq1_p3 edad_riq2_p3 edad_riq3_p3 edad_riq4_p3 edad_riq5_p3 edad_x, connect(l l l l l)  msymbol(S T O + X ) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).5, nogrid) xtitle("Edad") xlabel(20(5)65) subtitle("Riqueza") legend(row(2))  name(col_pr_edad_riq, replace)
	*Etnia | salud=malo
	quietly: scatter edad_etn_p3 edad_netn_p3 edad_x, connect(l l l l l)  msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).5, nogrid) xtitle("Edad") xlabel(20(5)65)  subtitle("Etnia")  name(col_pr_edad_etnia, replace)
	*EPS| salud=malo
	quietly: scatter edad_epsno_p3 edad_epsc_p3 edad_epss_p3 edad_epse_p3 edad_x,  connect(l l l l l)  msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).5, nogrid) xtitle("Edad") xlabel(20(5)65) subtitle("Eps") legend(row(2)) name(col_pr_edad_eps, replace)	
	
	graph combine col_pr_edad_sexo  col_pr_edad_etnia, ycommon xcommon graphregion(fcolor(white)) ysize(3) name(col_pr_edad_sexo_etn, replace) saving("${G]col_pr_edad_sexo_etn", replace)
	graph export "${G}col_pr_edad_sexo_etn.png", replace name("col_pr_edad_sexo_etn") width(1200) height(800)
	graph combine col_pr_edad_riq col_pr_edad_eps, ycommon xcommon graphregion(fcolor(white)) ysize(3) name(col_pr_edad_riq_eps, replace) saving("${G]col_pr_edad_riq_eps", replace)
	graph export "${G}col_pr_edad_riq_eps.png", replace name("col_pr_edad_riq_eps") width(1200) height(800)

*** Educación
	
	quietly: prgen educacion, generate(edu_) ncases(23)
	*Sexo
	quietly: prgen educacion, x(sexo=1) generate(edu_sex1_)  ncases(23)
	quietly: prgen educacion, x(sexo=0) generate(edu_sex0_)  ncases(23)
	*Obesidad y bajopeso
	quietly: prgen educacion, x(obesidad=1 bajopeso=0) generate(edu_obes_)  ncases(23)
	quietly: prgen educacion, x(obesidad=0 bajopeso=1) generate(edu_bajo_)  ncases(23)
	quietly: prgen educacion, x(obesidad=0 bajopeso=0) generate(edu_nutr_)  ncases(23)

	* Labels
	label var edu_p1 "Muy Bueno"
	label var edu_p2 "Bueno"
	label var edu_p3 "Malo"
	label var edu_sex1_p3 "Hombres"
	label var  edu_sex0_p3 "Mujeres"
	label var edu_obes_p3 "Obesos" 
	label var edu_bajo_p3 "Bajo peso"
	label var edu_nutr_p3 "Normal"
	
	outsheet edu_x edu_p1 edu_p2 edu_*p3 in 1/23 using "${T}col_prgen_edu.csv", comma replace
	
	*************
	*GRAFICAS*
	*************

	*  Todos los estados de salud educacion
	quietly: scatter edu_p1 edu_p2 edu_p3 edu_x, connect(l l l)  msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).7, nogrid) xtitle("Años de educación") xlabel(0(2)22)  name(col_pr_edu, replace) saving("${G]col_pr_edu", replace)
	graph export "${G}col_pr_edu.png", replace name("col_pr_edu") width(1200) height(800)

	* Hombre vs Mujer vs General | salud=Malo
	quietly: scatter edu_sex1_p3 edu_sex0_p3  edu_x, connect(l l l)   msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0.05(.05).5, nogrid) xtitle("Años de educación") xlabel(0(2)22) subtitle("Sexo") name(col_pr_edu_sex, replace)

	*** Obesidad
	quietly: scatter edu_obes_p3 edu_bajo_p3  edu_nutr_p3 edu_x, connect(l l l)   msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0.05(.05).5, nogrid) xtitle("Años de educación") xlabel(0(2)22)  subtitle("Estado nutricional") name(col_pr_edu_obes, replace)
	
	graph combine col_pr_edu_sex col_pr_edu_obes, ycommon xcommon graphregion(fcolor(white)) ysize(3) name(col_pr_edu_sex_obes, replace) saving("${G]col_pr_edu_sex_obes", replace)
	graph export "${G}col_pr_edu_sex_obes.png", replace name("col_pr_edu_sex_obes") width(1200) height(800)

 
 

*** Modelo Departamentos
set more off
use "${B}regresion_colombia", clear

global indep "edad sexo tamaño_hogar estado_civil etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso urbano"
global indep2 "edad sexo tamaño_hogar etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso"

foreach x in atlantico bolivar cesar cordoba guajira magdalena sucre san_andres{
local a=substr("`x'",1,3)
eststo modelo`a': mlogit salud ${indep} [pw=pon] if `x'==1, nolog rrr

if "`a'"=="atl"{
esttab modelo`a' using "${T}reg_deptos.csv",  replace cells(`"b(fmt(3) label("Coef.")) & _star"')  starlevels(** 0.05) drop("o.*" ) unstack  plain ///
mlabels("Modelo `a'", span) eqlabels("Muy Bueno" "Malo") eform
}
else {
esttab modelo`a' using "${T}reg_deptos.csv",  append cells(`"b(fmt(3) label("Coef.")) & _star "')  starlevels(** 0.05) drop("o.*" ) unstack  plain ///
mlabels("Modelo `a'", span) eqlabels("Muy Bueno" "Malo") eform
}
* 
}
*

stcmd "${T}reg_deptos.csv" "${T}deptos_regresion.xlsx" /y 
erase "${T}reg_deptos.csv"

*** Gráfica PIB, GINI, Salud Percibida

set more off
use "${B}regresion_colombia", clear

