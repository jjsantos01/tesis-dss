***********************************************************************************
***************************     Lectura ENDS 2010    **********************************
***************************        12-mayo-2012      *************************************
***************************      by: Juan Santos O.   ***********************************
***************************        Unicartagena      *************************************
***********************************************************************************

* Modificado: 2012-10-16

*-------------------------------------------------------------------------------------------------------------*
* DESCRIPCION: Carga los datos de la Encuesta nacional de Demografia y Salud 2010 (ENDS)  *
* ARCHIVOS DE ENTRADA: COPR60FL.dta
* ARCHIVOS DE SALIDA: ENDS_2010.dta
*------------------------------------------------------------------------------------------------------------*


*--------------------------------------------*
*               PRELIMINARES           *
*--------------------------------------------*

clear all

set more off

set mem 450m


*--------------------------------------------------------*
* ESTABLECIENDO DIRECTORIO DE TRABAJO *
*--------------------------------------------------------*

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
}
*


*


*---------------------------------------------------------*
*                 INTRODUCIENDO DATOS     *
*---------------------------------------------------------*

{
* Ingresando datos

use sh40 hv005 hv105 hv104 hv106 hv009 hv115 sh08 sh16 sh18 hv108 hv109	hv270 hv271 sh49b	sh38	shbm	sh49d sh49e hv025 shdepto	sh67	sh41	sh42a	sh42b	sh42c	sh42d	sh42e	sh42f	sh42g	sh42h	sh42i sh49b sh71 sh79 sh80 shestrdi hv001 shsd7 sh105 sh106 hv024 shsubreg using  "${B2}COPR60FL", clear


* Ponderador (pw)

gen pon=hv005/1000000

* Configurando diseño de encuesta

svyset hv001 [pw=pon], strata(shestrdi)

* Variable edad (categoría omitida: >=60)

gen edad=hv105 if hv105!=98
gen edad_1=(hv105>=16 & hv105<=44) if hv105!=.  &  hv105!=98
gen edad_2=(hv105>=45 & hv105<=59) if hv105!=. &  hv105!=98

* variable grupos de edad

gen grupo_edad=1 if edad>=18 & edad<=24
replace grupo_edad=2 if edad>=25 & edad<=34
replace grupo_edad=3 if edad>=35 & edad<=44
replace grupo_edad=4 if edad>=45 & edad<=54
replace grupo_edad=5 if edad>=55 & edad<=64
replace grupo_edad=6 if edad>=65

label var grupo_edad "Grupo de edad"

label define grupo_edad 1 "Entre 18 y 24" 2 "Entre 25 y 34" 3 "Entre 35 y 44" 4 "Entre 45 y 54" 5 "Entre 55 y 64" 6 "65 o más"
label values grupo_edad grupo_edad

* variable sexo (1 para hombres)

gen sexo=(hv104==1)

label var sexo "Sexo"
label define sexo 1 "Hombre" 0 "Mujer"
label values sexo sexo

* Variable tamaño del hogar

gen tamaño_hogar=hv009

* variable estado civil (1 si es casado o viven juntos)

gen estado_civil=(hv115==1 | hv115==2) if hv115!=8

* Variable pertenencia étnica ( 1 si pertenece a una étnia)

gen etnia=(sh08!=6)

label var etnia "Pertenencia étnica"
label define etnia 1 "Étnicos" 0 "No étnicos"
label values etnia etnia

* Variable ocupacion (1 si es ocupado)

gen ocupacion=(sh16==1 | sh16==2) & sh16!=98
rename sh16 ocupado_cat

* Variable recible algun ingreso (1 si recibe ingresos)

gen ingresos=(sh18==8) if sh18!=.

* Nivel educativo (categoria de comparación: Sin educación)

forvalues i=1(1)5{
gen educacion_`i'=(hv109==`i') if hv109!=8
}

gen edu_1=(hv109==1 | hv109==2) if hv109!=8
gen edu_2=(hv109==3 | hv109==4) if hv109!=8
gen edu_3=(hv109==5) if hv109!=8

gen educacion=hv108 if hv108!=98

rename hv106 nivel_educativo

* Quintil de riqueza

tab hv270, gen(riqueza_)
rename hv270 riqueza

* Estrato socioeconómico

tab sh49b if sh49b!=0 & sh49b!=8, nol g(estrato_)

*  Afiliacion a salud
gen eps_cont=(sh38==1) if sh38!=8
gen eps_sub=(sh38==2) if sh38!=8
gen eps_esp=(sh38==3) if sh38!=8
gen eps_no=(sh38==4) if sh38!=8

* Índice de Masa Corporal (1 si la persona tiene sobrepeso)

replace shbm=. if shbm==9999 | shbm==9998
rename shbm imc

gen sobrepeso=(imc>=2500) if imc!=.
gen obesidad=(imc>=3000) if imc!=.
gen bajopeso=(imc<1850) if imc!=.

rename shsd7 imc_who
rename sh105 peso
rename sh106 estatura

* Servicio de acueducto (1 si el hogar tiene acueducto)

rename sh49d acueducto

* Servicio de alcantarillado (1 si el hogar tiene alcantarillado)

rename sh49e alcantarillado

* Región y departamento

gen caribe=(shdepto==8 | shdepto==13 | shdepto==20| shdepto==23| shdepto==44| shdepto==47| shdepto==70 | shdepto==88)
gen atlantico=(shdepto==8)
gen bolivar=(shdepto==13)
gen cesar=(shdepto==20)
gen cordoba=(shdepto==23)
gen guajira=(shdepto==44)
gen magdalena=(shdepto==47)
gen sucre=(shdepto==70)
gen san_andres=(shdepto==88)

* area ( 1 si es urbano)

gen urbano=(hv025==1)
rename hv025 area

* Estado percibido de salud (1 excelente 5 malo)

rename sh40 salud
gen salud2=salud

recode salud (2=1) (3=2) (4=3) (5=3)

label define salud 1 "Muy bueno" 2 "bueno" 3 "malo", replace
label values salud salud

* Tiene alguna discapacidad

foreach x in a b c d e f g h i{
replace sh42`x'=0 if sh42`x'==8
}
gen discapacidad=(sh42a!=0 | sh42b!=0 | sh42c!=0 | sh42d!=0 | sh42e!=0 | sh42f!=0 | sh42g!=0 | sh42h!=0 | sh42i!=0 )

* Ha visitado al docor en el ultimo año (1 si sí ha visitado)

gen doctor=(sh41==1)

* Ha tenido problema de salud

gen problema=(sh71!=.)

* Hospitalizado y dias de hospitalizacion

gen hospital=(sh79!=.)
gen dias_hosp=sh80

* Departamento y region

rename shdepto depto
rename hv024 region
rename shsubreg subreg

* Borrando variables que no se utilizan
drop  hv005 hv009 hv271  sh49b sh67 hv104 hv105 hv108 hv109 hv115 sh08  sh38

save "${B}ends_2010", replace
save  "${PUB}ends_2010", replace

************************************************************************
********** Generando base de regresión Caribe***************************
*************************************************************************

use  "${B}ends_2010", clear

keep if edad>=18 & caribe==1

global indep "edad sexo tamaño_hogar estado_civil etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso urbano alcantarillado"
global indep2 "edad sexo tamaño_hogar etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso alcantarillado"
** Borrando Missing values
foreach x of global indep{
drop if `x'==.
}

save "${B}regresion_caribe", replace

************************************************************************
********** Generando base de regresión Colombia*************************
*************************************************************************

use  "${B}ends_2010", clear

keep if edad>=18 & edad<=64

global indep "edad sexo tamaño_hogar estado_civil etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso urbano alcantarillado"
global indep2 "edad sexo tamaño_hogar etnia ocupacion educacion riqueza_2 riqueza_3 riqueza_4 riqueza_5 eps_cont eps_sub eps_esp obesidad bajopeso alcantarillado"
** Borrando Missing values
foreach x of global indep{
drop if `x'==.
}

save "${B}regresion_colombia", replace

************************************************************************
********** Generando base diferencias de género*************************
*************************************************************************

use  "${B}ends_2010", clear

keep if edad>=18 & edad<=64
}
*

