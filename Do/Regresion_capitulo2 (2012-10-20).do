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
log using "${L}regresion.smcl", replace
use "${B}regresion_caribe", clear

global indep "edad sexo tamaño_hogar estado_civil etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso urbano"
global indep2 "edad sexo tamaño_hogar etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso"

* Probando supuesto de líneas paralelas probit ordenado


omodel logit salud ${indep}
*
ologit salud ${indep}
estadd brant, detail
mat brant=(e(brant_chi2), e(brant_p)\e(brant)')
esttab matrix(brant, fmt(%5.3f)) using "${T}brant.csv", plain replace
stcmd "${T}brant.csv" "${T}brant.xlsx" /y 
erase "${T}brant.csv"
*/


** Estimando modelo logit multinomial
set more off
quietly:eststo modelo1: svy: mlogit salud ${indep}, nolog rrr

** Exportando tabla con resultados

esttab modelo1 using "${T}resultados_regresion.csv",  replace cells(`"b(fmt(3) label("Coef.")  ) p(fmt(3) label("p-valor")) & _star ci(fmt(3))"')  starlevels(** 0.05) drop("o.*" ) unstack  plain ///
mlabels("Modelo Región Caribe", span) eqlabels("Muy Bueno" "Malo") eform
stcmd "${T}resultados_regresion.csv" "${T}resultados_regresion.xlsx" /y 
erase "${T}resultados_regresion.csv"

esttab modelo1 using "${T}grafica_ci.csv" ,  replace cells(`"b(fmt(3) label("Coef.")  ) ci(fmt(%4.3f))"')  starlevels(* 0.10 ** 0.05 *** 0.01) drop("o.*" ) unstack  plain eform

*** Pruebas de ajuste
set more off
quietly: mlogit salud ${indep} [pw=pon], nolog rrr
estadd fitstat
mat bondad=e(ll_0)\e(ll)\e(dev)\e(lrx2_p)\e(r2_mf)\e(r2_mfadj)\e(r2_ml)\e(r2_cu)\e(aic0)\e(statabic)
mat rownames bondad="LL0" "LL Full" "Deviance" "LL p" "R2MF" "R2MFAJ" "R2ML" "R2CU" "AIC" "BIC"	
esttab matrix(bondad, fmt(%10.3f)) using "${T}bondad.csv", plain replace
stcmd "${T}bondad.csv" "${T}bondad.xlsx" /y 
erase "${T}bondad.csv"

* Prueba de Hosmer y Lemeshov

mlogitgof, group(400)

*** Test Wald para probar que todas las variables son conjuntamente diferentes de 0

mlogtest, wald set(${indep})

*** Modelo sin las variables Urbano y Estado civil

quietly:eststo modelo2: svy: mlogit salud ${indep2}
esttab modelo2 using "${T}modelo2.csv",  replace cells(`"b(fmt(3) label("Coef.")  ) p(fmt(3) label("p-valor")) & _star "')  starlevels(* 0.10 ** 0.05 *** 0.01) drop("o.*" ) unstack  plain ///
mlabels("Modelo Región Caribe", span) eqlabels("Muy Bueno" "Malo")eform
stcmd "${T}modelo2.csv" "${T}modelo2.xlsx" /y 
erase "${T}modelo2.csv"

set more off
quietly: mlogit salud ${indep2} [pw=pon]
estadd fitstat
mat bondad2=e(ll_0)\e(ll)\e(dev)\e(lrx2_p)\e(r2_mf)\e(r2_mfadj)\e(r2_ml)\e(r2_cu)\e(aic0)\e(statabic)
mat rownames bondad2="LL0" "LL Full" "Deviance" "LL p" "R2MF" "R2MFAJ" "R2ML" "R2CU" "AIC" "BIC"	
esttab matrix(bondad2, fmt(%10.3f)) using "${T}bondad2.csv", plain replace
stcmd "${T}bondad2.csv" "${T}bondad2.xlsx" /y 
erase "${T}bondad2.csv"

*** Gráfica de CI*****
clear all
insheet using "${T}grafica_ci.csv", clear
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
 ytitle("") xtitle(" " "Riesgo relativo") legend(label(1 "Intervalo de confianza") label(2 "RRR") size(*.7)) xline(1, lpattern("-") lwidth(*.5)) || scatter  variable rrr_mb, mlabel(rrr_mb) mlabpos(6) mlabgap(0.05) mlabsize(*0.8) title("Muy bueno" " ", size(*.7)) name("ci_mb", replace) saving("${G}ci_mb", replace)

  tw rcap ci_up_m ci_low_m variable, horizontal ylabel(1 "Edad" 2 "Sexo" 3 "Tamaño hogar" 4 "Estado civil" 5 "Etnia" 6 "Ocupado" 7 "Educacióin" 8 "Quintil 2" 9 "Quintil 3" 10 "Quintil 4" 11 "Quintil 5" 12 "Reg. Contributivo" 13 "Reg. Subsidiado" 14 "Reg. Especial" 15 "Obesidad" 16"Bajo peso" 17 "Urbano", labsize(small) angle(0)) yscale(reverse) graphregion(fcolor(white)) ///
 ytitle("") xtitle(" " "Riesgo relativo") legend(label(1 "Intervalo de confianza") label(2 "RRR") size(*.7)) xline(1, lpattern("-") lwidth(*.5)) || scatter  variable rrr_m, mlabel(rrr_m) mlabpos(6) mlabgap(0.05) mlabsize(*0.8) title("Malo" " ", size(*.7)) name("ci_m", replace) saving("${G}ci_m", replace)
 
graph combine "${G}ci_mb" "${G}ci_m", graphregion(fcolor(white)) name(ci, replace) saving("${G}ci", replace)
graph export "${G}ci.png", replace name ("ci") width(1200) height(800)


 
 ** Probabilidades predichas para cada Categoría

use "${B}regresion_caribe", clear
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

esttab matrix(EP, fmt(%5.3f)) using "${T}efectos_promedio.csv", plain replace
stcmd "${T}efectos_promedio.csv" "${T}efectos_promedio.xlsx" /y 
erase "${T}efectos_promedio.csv"

* Efectos Marginales en las medias

mfx compute, predict(outcome(1))
mat EM1=e(Xmfx_dydx)'
mfx compute, predict(outcome(2))
mat EM2=e(Xmfx_dydx)'
mfx compute, predict(outcome(3))
mat EM3=e(Xmfx_dydx)'
mat EMX=e(Xmfx_X)'
mat EM=EMX,EM1,EM2,EM3
mat colnames EM="Media" "Muy Bueno" "Bueno" "Malo"

esttab matrix(EM, fmt(%5.3f)) using "${T}efectos_marginales.csv", plain replace
stcmd "${T}efectos_marginales.csv" "${T}efectos_marginales.xlsx" /y 
erase "${T}efectos_marginales.csv"
*** Gráfica de probabilidades

dotplot MB B M, graphregion(fcolor(white))ytitle("Probabilidad estimada") xtitle("Frecuencia") ///
name("dist_salud", replace) saving("${G}dist_salud", replace) 
graph export "${G}dist_salud.png", replace name ("dist_salud") width(1200) height(800)

*** Tabla de contingencia Hosmer y Lemeshow

gen CB=1-B
sort CB
_pctile CB, p(10 20 30 40 50 60 70 80 90)

forvalues i=1/9{
scalar p`i'=r(r`i')
}
scalar p0=0
scalar p10=1

set more off
local h=1
local k=1
forvalues i=0/9{
estpost tabstat MB B M if CB>p`i' & CB<=p`h++', statistics(sum)
mat M=e(M)
mat B=e(B)
mat MB=e(MB)

local m=p`k++'
forvalues j=1/3{
count if salud==`j' & CB>p`i' & CB<=`m'
mat b`j'=r(N)
}

mat a`i'=b3,M,b2,B,b1,MB
mat rownames a`i'="p`i'"
}
*
mat tabla_HL=a0\a1\a2\a3\a4\a5\a6\a7\a8\a9
esttab matrix(tabla_HL, fmt(%7.0f)) using "${T}tabla_HL.csv", plain replace
stcmd "${T}tabla_HL.csv" "${T}tabla_HL.xlsx" /y 
erase "${T}tabla_HL.csv"

** Probabilidades para perfiles específicos
set more off
quietly: use "${B}regresion_caribe", clear
svy: mlogit salud ${indep}, nolog rrr
* Hombre, quintil 2, sin educacion,

estadd prvalue, x(sexo=1 riqueza_2=0 riqueza_3=0 riqueza_4=0 riqueza_5=0 educacion=0) label(Sex1Riq1Edu0) replace

* Mujer, quintil 2, sin educacion,

estadd prvalue, x(sexo=0 riqueza_2=0 riqueza_3=0 riqueza_4=0 riqueza_5=0 educacion=0) label(Sex0Riq1Edu0)

* Hombre, quintil 2, bachiller,

estadd prvalue, x(sexo=1 riqueza_2=1 riqueza_3=0 riqueza_4=0 riqueza_5=0 educacion=11) label(Sex1Riq2Edu11)

* Mujer, quintil 2, Bachiller,

estadd prvalue, x(sexo=0 riqueza_2=1 riqueza_3=0 riqueza_4=0 riqueza_5=0 educacion=11) label(Sex0Riq2Edu11)

* Hombre, quintil 5, profesional

estadd prvalue, x(sexo=1 riqueza_2=0 riqueza_3=0 riqueza_4=0 riqueza_5=1 educacion=16) label(Sex1Riq5Edu16)

* Mujer, quintil 5, profesional,

estadd prvalue, x(sexo=0 riqueza_2=0 riqueza_3=0 riqueza_4=0 riqueza_5=1 educacion=16) label(Sex0Riq5Edu16)

* Ocupado, Étnico,Bachiller

estadd prvalue, x(ocupacion=1 etnia=1 educacion=11)  label(Ocu1Etn1Edu11)

* Ocupado, No Étnico, Bachiller

estadd prvalue, x(ocupacion=1 etnia=0 educacion=11)  label(Ocu1Etn0Edu11)

* Profesional, Ocupado, Eps contr
estadd prvalue, x(educacion=16 ocupacion=1 eps_cont=1 eps_sub=0 eps_esp=0)  label(Edu16Ocu1Con)

* Bachiller, Ocupado , Eps subs

estadd prvalue, x(educacion=11 ocupacion=1 eps_cont=0 eps_sub=1 eps_esp=0)  label(Edu11Ocu1Sub)


*Exportando resultados de prvalue
mat M1=e(_estadd_prvalue)'
mat M2=M1[1,1...]',M1[13,1...]', M1[7,1...]'

esttab matrix(M2, fmt(%5,3f)) using "${T}perfiles.csv", plain replace
stcmd "${T}perfiles.csv" "${T}perfiles.xlsx" /y 

** Gráfica perfiles
clear all
insheet using "${T}perfiles.csv", clear
	drop if v1==""
	destring v2 v3 v4, dpcomma replace
	encode v1, gen(perfil)
	label define perfil 1 "Bachiller, Ocupado, R. Subsidiado" 2 "Profesional, Ocupado, R. Contributivo" 3 "Ocupado, No étnico, Bachiller" 4 "Ocupado,Étnico, Bachiller" 5 "Mujer, Quintil 1, Sin educación" 6 "Mujer, Quintil 2, Bachiller" 7 "Mujer, Quintil 5, Profesional" 8 "Hombre, Quintil 1, Sin educación" 9 "Hombre, Quintil 2, Bachiller" 10 "Hombre, Riqueza 5, Profesional", replace
	label value perfil perfil
	label var v2 "Muy Bueno"
	label var v3 "Bueno"
	label var v4 "Malo"
	
	graph hbar v2 v3 v4, over(perfil, sort(v4) label(labsize(*.9))) bar(1, fcolor(green*0.7) lcolor(black)) bar(2, fcolor(yellow) lcolor(black)) bar(3, fcolor(red*.8) lcolor(black)) graphregion(fcolor(white)) ///
	stack  ytitle("Probabilidad") legend(label(1 "Muy Bueno") label(2 "Bueno") label(3 "Malo") rows(1) ) blabel(bar,  pos(center) format(%5,2f)) name("perfiles", replace) saving("${G}perfiles", replace)
	
	graph export "${G}perfiles.png", replace name("perfiles") width(1200) height(800)

*** Gráficas de probabilidad

use "${B}regresion_caribe", clear
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
	
	quietly: prgen educacion, generate(edu_) ncases(23)
	*Sexo
	quietly: prgen educacion, x(sexo=1) generate(edu_sex1_)  ncases(23)
	quietly: prgen educacion, x(sexo=0) generate(edu_sex0_)  ncases(23)
	*Obesidad y bajopeso
	quietly: prgen educacion, x(obesidad=1 bajopeso=0) generate(edu_obes_)  ncases(23)
	quietly: prgen educacion, x(obesidad=0 bajopeso=1) generate(edu_bajo_)  ncases(23)
	quietly: prgen educacion, x(obesidad=0 bajopeso=0) generate(edu_nutr_)  ncases(23)

	outsheet  edad_p1 edad_p2 edad_p3 edad_sex1_p3 edad_sex0_p3 edad_riq1_p3 edad_riq2_p3 edad_riq3_p3 edad_riq4_p3 edad_riq5_p3 edad_etn_p3 edad_netn_p3 edad_epsno_p3 edad_epsc_p3 edad_epss_p3 edad_epse_p3 edad_x using "${T}pr_edad_caribe.csv" in 1/20
	outsheet edu_p1 edu_p2 edu_p3 edu_x edu_sex1_p3 edu_sex0_p3 edu_obes_p3 edu_bajo_p3  edu_nutr_p3 using "${T}pr_edu_caribe.csv" in 1/23
	
	**** Gráficas
	
	insheet using "${T}pr_edad_caribe.csv", clear
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

	
	*************
	*GRAFICAS**
	*************
	
	* Todos los estados de salud
	
	* Scatter
	quietly: scatter edad_p1 edad_p2 edad_p3 edad_x, connect(l l l)  msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).7, nogrid) xtitle("Edad") xlabel(20(5)65)  saving("${G}pr_edad", replace) name(pr_edad, replace) 
	graph export "${G}pr_edad.png", replace name ("pr_edad") width(1200) height(800)
	
	* Area
	replace edad_p2=edad_p2+edad_p3
	replace edad_p1=edad_p2+edad_p1
	
	tw area  edad_p1 edad_p2 edad_p3 edad_x, ylabel(0(0.2)1) graphregion(fcolor(white)) ytitle("Probabilidad")  xtitle("Edad") xlabel(20(5)64)  fcolor(green*0.7 yellow red*.8) lcolor(black black black) legend(rows(1)) name("pr_edad_area", replace) saving("${G}pr_edad_area", replace)
	graph export "${G}pr_edad_area.png", replace name ("pr_edad_area") width(1200) height(800)
	
	*  Hombre vs Mujer vs General | salud=Malo
	
	* Scatter
	quietly: scatter edad_sex1_p3 edad_sex0_p3 edad_x, connect(l l l) msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).5, nogrid) xtitle("Edad") xlabel(20(5)65) subtitle("Sexo") name(pr_edad_sexo, replace)
	
	*  Riqueza | salud=Malo
	quietly: scatter edad_riq1_p3 edad_riq2_p3 edad_riq3_p3 edad_riq4_p3 edad_riq5_p3 edad_x, connect(l l l l l)  msymbol(S T O + X ) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).5, nogrid) xtitle("Edad") xlabel(20(5)65) subtitle("Riqueza") legend(row(2))  name(pr_edad_riq, replace)
	*Etnia | salud=malo
	quietly: scatter edad_etn_p3 edad_netn_p3 edad_x, connect(l l l l l)  msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).5, nogrid) xtitle("Edad") xlabel(20(5)65)  subtitle("Etnia")  name(pr_edad_etnia, replace)
	*EPS| salud=malo
	quietly: scatter edad_epsno_p3 edad_epsc_p3 edad_epss_p3 edad_epse_p3 edad_x,  connect(l l l l l)  msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).5, nogrid) xtitle("Edad") xlabel(20(5)65) subtitle("Eps") legend(row(2)) name(pr_edad_eps, replace)	
	
	graph combine pr_edad_sexo  pr_edad_etnia, ycommon xcommon graphregion(fcolor(white)) ysize(3) name(pr_edad_sexo_etn, replace) saving("${G}pr_edad_sexo_etn", replace)
	graph export "${G}pr_edad_sexo_etn.png", replace name ("pr_edad_sexo_etn") width(1200) height(800)
	graph combine pr_edad_riq pr_edad_eps, ycommon xcommon graphregion(fcolor(white)) ysize(3) name(pr_edad_riq_eps, replace) saving("${G}pr_edad_riq_eps", replace)
	graph export "${G}pr_edad_riq_eps.png", replace name ("pr_edad_riq_eps") width(1200) height(800)

*** Educación
	
	
	* Labels
	label var edu_p1 "Muy Bueno"
	label var edu_p2 "Bueno"
	label var edu_p3 "Malo"
	label var edu_sex1_p3 "Hombres"
	label var  edu_sex0_p3 "Mujeres"
	label var edu_obes_p3 "Obesos" 
	label var edu_bajo_p3 "Bajo peso"
	label var edu_nutr_p3 "Normal"
	
	*************
	*GRAFICAS*
	*************
	
	*  Todos los estados de salud educacion
	quietly: scatter edu_p1 edu_p2 edu_p3 edu_x, connect(l l l)  msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0(.1).7, nogrid) xtitle("Años de educación") xlabel(0(2)22)  saving("${G}pr_edu", replace) name(pr_edu, replace)
	graph export "${G}pr_edu.png", replace name ("pr_edu") width(1200) height(800)

	* Hombre vs Mujer vs General | salud=Malo
	quietly: scatter edu_sex1_p3 edu_sex0_p3  edu_x, connect(l l l)   msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0.2(.05).5, nogrid) xtitle("Años de educación") xlabel(0(2)22) subtitle("Sexo") name(pr_edu_sex, replace)

	*** Obesidad
	quietly: scatter edu_obes_p3 edu_bajo_p3  edu_nutr_p3 edu_x, connect(l l l)   msymbol(S T O) graphregion(fcolor(white)) ytitle("Probabilidad") ylabel(0.2(.05).5, nogrid) xtitle("Años de educación") xlabel(0(2)22)  subtitle("Estado nutricional") name(pr_edu_obes, replace)
	
	graph combine pr_edu_sex pr_edu_obes, ycommon xcommon graphregion(fcolor(white)) ysize(3) name(pr_edu_sex_obes, replace) saving("${G}pr_edu_sex_obes", replace)
	graph export "${G}pr_edu_sex_obes.png", replace name ("pr_edu_sex_obes") width(1200) height(800)


log close

disp(`"para ver resultados {stata `"view "${L}regresion.smcl""': log }"')
 


