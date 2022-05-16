* Instruction 1): write the next command line to import Excel data:
* u1="Data_input_minigrid4sh"  -s .\restart\restart.g00

* iNSTRUCTION "2) is it total failute or capacity shortage (minigrid as back-up)

$Title "Optimal Dispatch of a Mini-grid connected to National Grid: UnderGrid" (Deterministic Model with Scenario Analysis)


$ontext
$Author: Tatiana Gonzalez Grandon (grandont@hu-berlin.de)
HU BERLIN /Energy Management

$offtext

* global options: allow empty and multiple definition of sets
$OnEmpty OnMulti
$Phantom null

* options

*OPTIONS LIMROW=0, LIMCOL=0, SOLPRINT=OFF;
OPTIONS LP=CPLEX, RMIP=CPLEX, MIP=CPLEX, RMIQCP=CPLEX, MIQCP=CPLEX;
OPTIONS RESLIM=1800, ITERLIM=2000000;
OPTIONS bratio=1 ;
OPTIONS THREADS=0;
OPTION  optcr=0.001;

* Defining SETS
Sets
t                  periods of time in hours
week               weeks
t2(t)              subset period of time first 24 hours
t3(t)              subset period of time second day
ay(week)           active week

* Defining PARAMETERS (ENDOGENOUS VARIABLES)
Parameters
***Taking row inputs from Excel (Time series)
E_PV(t)             maximum solar generation PV panel        [kW]
d_loadA(t)          total load of the microgrid from customers type A [kW]
d_loadB(t)          total load of the microgrid from customers type B [kW]
xi(t)               hours of Grid working equal to 2 and failure equals to 1
p_grid_export(t)    price for exporting energy to the main grid [$]
c_grid_import(t)    price for exporting energy to the main grid [eur per kWh]
***

*number of weeks considered in the optimization
active_weeks  number of the week (scenario) considered in the optimization

* marginal cost of PV [eur/kWh]
c_pv

* marginal cost of battery supply [eur/kWh]
c_bess_discharge

* marginal cost of diesel (FUEL COST) [eur/L]
c_diesel

*cost of not served energy
c_nse

* quantity of customers of type A (Residents)
q_A

*quantity of customers of type B (Productive Users)
q_B

*price of electricity customers A  [eur/kWh]
p_A

*price of electricity customers B  [eur/kWh]
p_B

* maximum output diesel generation  [kW]
E_diesel

* maximum storage capacity  [kWh]
SOC_max

* minimum storage capacity  [kWh]
SOC_min

* Charge Limit / storage maximal consumption [kWh]
L_charge

* Discharge Limit / storage maximal generation [kWh]
L_discharge

* charging efficiency
eta_char_bess

* discharging efficiency
eta_disc_bess

* initial storage capacity  [kWh]
SOC_ini 

* max electricity flow from the grid [kwh]
G_max

* min electricity flow from the grid [kwh]
G_min

* Lower bound of diesel generator [kW]
l_diesel

* Diesel generator start-up cost [$]
STC_diesel

* Minimum running time of the diesel genset (must be a natural number)
MRT

* Minimum resting time before turnin diesel on again (must be a natural number)
RT

* Intercept coefficient of the fuel curve
b

* Slope coefficient of the fuel curve [L/hr/kW]
m

* Average efficiency parameter of diesel genset
eta_diesel

* Self-discharge rate of the battery
sigma

* Nominal power of PV inverter [kW]
E_inv_pv

* Average efficiency of PV inverter
eta_inv

* Nominal power of BESS inverter-rectifier [kW]
E_ir

* Average efficiency of BESS inverter
eta_BESS_inv

* Average efficiency of rectifier
eta_rect

*Reliability level for customer B
reliab_b
;

* Defining scalars
* =====================
Scalars
    epsilon             # small number                            /1e-6/
    s_EXETIME /3330/
;

* Defining variables
* =======================

Variables
obj   total social welfare ;

Positive Variables
d_BESS_charge(t)       Charging of Battery at time t [kWh] 

ee_pv(t)                electricity output of PV at time t [kWh]

ee_diesel(t)            electricity output of diesel at time t [kWh]

e_BESS_discharge(t)    Discharge of Battery at time t [kWh]

e_grid_import(t)       electricity imported from the Main Grid at time t [kWh]

e_grid_export(t)       electricity exported to the Main Grid at time t [kWh]

e_NSE_A(t)               non-served electricity consumer A at time t

e_NSE_B(t)               non-served electricity consumer B  at time t

SOC(t)                 state of charge of BESS at time t;
;

Binary Variables
u(t) discharge of Bess if equal to 1
v(t) charge of Bess if equal to 1
s(t) export to the Main Grid at time t if equal to 1
w(t) diesel generator on if equal to 1
r(t) diesel generator starts to run in time t if equal to 1
zeta(t) diesel generator stopped at time t if equal to 1
;

* Begin *************INCLUDE OF DATA FROM EXCEL**********************************
;
$setglobal namemodel undergrid

$onecho > tmp_%namemodel%_%gams.user1%.txt
   r1 = sets
   o1 = sets_%namemodel%_"%gams.user1%".txt
   r2 = parameters
   o2 = parameters_%namemodel%_"%gams.user1%".txt
$offecho

$call xls2gms m i="%gams.user1%".xlsm @"tmp_%namemodel%_%gams.user1%.txt"


$ontext
   r3= GridFailure
   o3 = GridFailure_%namemodel%_"%gams.user1%".txt
   r4= EPV
   o4 = EPV_%namemodel%_"%gams.user1%".txt
   r5 = loadA
   o5 = loadA_%namemodel%_"%gams.user1%".txt
   r6 = loadB
   o6 = loadB_%namemodel%_"%gams.user1%".txt
   r7 = loadG
   o8 = loadG_%namemodel%_"%gams.user1%".txt
*   r3 = genPV
*   o3 = genPV_%namemodel%_"%gams.user1%".txt
*   r4 = load
*   o4 = load_%namemodel%_"%gams.user1%".txt
$offtext

sets
$include sets_%namemodel%_%gams.user1%.txt
;
$include parameters_%namemodel%_%gams.user1%.txt
;

* genPV_%namemodel%_%gams.user1%.txt cambiar!
table    E_PV_weeks(t,week)
$include genPV_%namemodel%_%gams.user1%_demo0.txt
;
* loadA_%namemodel%_%gams.user1%.txt cambiar! 
table    d_loadA_weeks(t,week)
$include loadA_%namemodel%_%gams.user1%_demo0A.txt
;
* loadB_%namemodel%_%gams.user1%.txt cambiar! 
table    d_loadB_weeks(t,week)
$include loadB_%namemodel%_%gams.user1%_demo0B.txt
;

* xi_%namemodel%_%gams.user1%.txt cambiar!
table    xi_weeks(t,week)
$include xi_%namemodel%_%gams.user1%_demo0xi.txt
;

* p_grid_export_%namemodel%_%gams.user1%.txt cambiar!
table    p_grid_export_weeks(t,week)
$include p_grid_export_%namemodel%_%gams.user1%_demo0xi.txt
;

* c_grid_import_%namemodel%_%gams.user1%.txt cambiar!
table    c_grid_import_weeks(t,week)
$include c_grid_import_%namemodel%_%gams.user1%_demo0xi.txt
;

* End *************INCLUDE OF DATA FROM EXCEL**********************************

* Alias set needing for looping in MRT and RT constraints 
alias (t, i) ; 

* Declaring NAMES of equations and constraints
* ========================

Equations
  welfare              Define objective function
  balance(t)            Power balance or 1st Kirchhoff Law
  cnsenA(t)              Constraint for Nse A
  cnsenB(t)              Constraint for Nse B
  elecpv(t)             Constraint of pv
  elecinverter_pv(t)    Constraint of maximum inverter capacity
  Storage(t)            Update SOC
  StorageMin(t)         State of Charge inequality (min)
  StorageMax(t)         State of Charge inequality (max)
  BessDisC(t)           Discharge constraint dep on SOC
  BessChaC(t)           Charge constraint dep on SOC
  Nop(t)                No charge-discharge at the same time
  BessDis2(t)           constraint intertemporal Discharge
  BessCha2(t)           constraint intertemporal charge
  diesel_upper(t)       constraint diesel upper limit
  diesel_lower(t)       constraint diesel lower limit
  diesel_binaries(t)    Relation between diesel binaries 
  diesel_min_run(t)     Enforcing minimum run time for diesel
  diesel_rest(t)        Enforcing minimun rest time for diesel
  ir_limit_charge(t)    Battery inverter charging limit 
  ir_limit_discharge(t) Battery inverter discharging limit
  GridExport(t)         constraint on quantity of electricity exported (sold)to main grid
  GridImport(t)         constraint on quantity of electricity imported (bought) from the main grid
*Reliability(t)        reliability of customer B 24 hours Re(t)                 reliability of customer B 48 hours
;

* Defining the equations and constraints
* ========================
*Welfare when Capacity Shortage Failure (Chage Grid Export constraint)
welfare.. obj =E= sum(t, p_A*d_loadA(t)*q_A-p_A*e_NSE_A(t)+p_B*d_loadB(t)*q_B-p_B*e_NSE_B(t)+p_grid_export(t)*e_grid_export(t)-c_diesel*(b*E_diesel*w(t) + m* ee_diesel(t))- (r(t) * STC_diesel)-c_pv*ee_pv(t)-c_grid_import(t)*e_grid_import(t));

*welfaree.. obj =E= sum(t,p_grid_export(t)*e_grid_export(t)-c_diesel*(b*E_diesel*w(t) + m* ee_diesel(t))- (r(t) * STC_diesel)-c_pv*ee_pv(t)-c_grid_import(t)*e_grid_import(t));
*welfare..obj=E=sum(t,c_diesel*(b*E_diesel*w(t) + m* ee_diesel(t))- (r(t) * STC_diesel)-c_pv*ee_pv(t)-c_grid_import(t)*e_grid_import(t));
*sum(t, p_A*d_loadA(t)*q_A+p_B*d_loadB(t)*q_B+p_grid_export(t)*e_grid_export(t)-c_diesel*(b*E_diesel + m* ee_diesel(t))- r(t) * STC_diesel-c_pv*ee_pv(t)-c_grid_import(t)*e_grid_import(t)-c_nse*e_NSE(t));
*add +SOC(t)*(1/SOC_max)*c_bess_discharge
*welfare..  z =E= sum(t, p_A*d_loadA(t)*q_A+p_B*d_loadB(t)*q_B+p_grid_export*e_grid_export(t)-c_pv*ee_pv(t)-c_grid_import*e_grid_import(t)-c_diesel*ee_diesel(t)-c_nse*e_NSE(t));
*welfare..  z =E= sum(t, p_A*d_loadA(t)*q_A+p_B*d_loadB(t)*q_B+p_grid_export*e_grid_export(t)-c_diesel*(b*E_diesel + m* ee_diesel(t))- r(t) * STC_diesel-c_pv*ee_pv(t)-c_grid_import*e_grid_import(t)-c_diesel*ee_diesel(t)-c_nse*e_NSE(t));
*-c_nse*e_NSE(t)

* Energy balance -e_NSE(t)
balance(t).. d_loadA(t)*q_A-e_NSE_A(t)+d_loadB(t)*q_B-e_NSE_B(t)+e_grid_export(t)+(1/(eta_char_bess*eta_rect))*d_BESS_charge(t)
              -eta_inv*ee_pv(t)-eta_disc_bess*eta_inv*e_BESS_discharge(t)-e_grid_import(t)-ee_diesel(t)=L=0 ;
              
*cost of not serving energy consumers
cnsenA(t).. d_loadA(t)*q_A-e_NSE_A(t)=G=0;
cnsenB(t).. d_loadB(t)*q_B-e_NSE_B(t)=G=0;
              

* PV and PV inverter constraints 
elecpv(t)..  ee_pv(t)- E_PV(t)=L=0;
elecinverter_pv(t).. ee_pv(t)*eta_inv - E_inv_pv =L= 0;

* Storage constraints
Storage(t) .. SOC(t) =E= SOC(t-1)$(not t.first)*(1 - sigma) + SOC_ini$(t.first)
                                       + [- e_BESS_discharge(t)
                                          + d_BESS_charge(t)
                                         ];
StorageMin(t).. SOC(t)-SOC_min=G=0;
StorageMax(t).. SOC(t)-SOC_max=L=0;

* Battery constraints
BessDisC(t).. e_BESS_discharge(t)=L=u(t)*L_discharge;
BessChaC(t).. d_BESS_charge(t)=L=v(t)*L_discharge;
Nop(t).. u(t)+v(t)=L=1;
BessDis2(t).. e_BESS_discharge(t)=L=SOC(t-1)$(not t.first) + SOC_ini$(t.first) - SOC_min;
BessCha2(t)..d_BESS_charge(t)+SOC(t-1)$(not t.first) + SOC_ini$(t.first)=L=SOC_max;

* Diesel constraints
diesel_upper(t)..  ee_diesel(t) - E_diesel * w(t) =L= 0;
diesel_lower(t)..  ee_diesel(t) - l_diesel * w(t) =G= 0;
diesel_binaries(t).. w(t) - w(t-1)$(not t.first) =E= r(t) - zeta(t);
diesel_min_run(t).. r(t) + sum(i$(ord(i)>= ord(t) AND ord(i)<= min(ord(t)+ MRT-1, card(t))), zeta(i)) =L= 1;
diesel_rest(t).. zeta(t) + sum(i$(ord(i)>= ord(t) AND ord(i)<= min(ord(t)+ RT-1, card(t))), r(i)) =L= 1;

* Inverter-rectifier constraints
ir_limit_charge(t).. d_BESS_charge(t) / eta_char_bess - E_ir =L= 0;
ir_limit_discharge(t).. eta_inv * eta_disc_bess * e_BESS_discharge(t) - E_ir =L= 0;

* Buenas ecuaciones con GRID. Recordar 2=failure 1=works We can always export but we cannnot import if it fails
*GridExport(t).. e_grid_export(t) -G_max*s(t) =L= 0;
*capacity shortage ahora escrito arriba

GridExport(t).. e_grid_export(t) -G_max*s(t)*(xi(t)-1) =L= 0;
GridImport(t).. e_grid_import(t) -(1-s(t))*G_max*(xi(t)-1) =L= 0;
*Total Failure actualmente WHICH IS
*GridExport(t).. e_grid_export(t) -G_max*s(t)*(xi(t)-1) =L= 0;
* if we want Capacity Shortage then subsitute: GridExport(t).. e_grid_export(t) -(2-xi(t))*G_max*s(t) =L= 0;

*Capacity Shortage Failure: I can Export but not Import to the Main Grid
*GridExport(t).. e_grid_export(t) -G_max*s(t) =L= 0;

*Reliability of Customer B
*Reliability(t)..reliab_b =G= e_NSE_B(t)/d_loadB(t);
*Reliability.. sum(t,e_NSE_B(t)/d_loadB(t))=L=reliab_b ; 
*Re(t).. sum(t3,e_NSE_B(t3)/d_loadB(t3))=L= reliab_b ; 

*reliab_b =G= e_NSE_B(t)/d_loadB(t);

Model undergrid /all/;

* Usa el fichero de opciones de GAMS
undergrid.OptFile           = 1;
* Tolerancia relativa del B&B
undergrid.optcr           = 0;
* Limite del tiempo de ejecuci�n
undergrid.reslim           = s_EXETIME * 60;
* Omite variables fijadas
undergrid.holdfixed           = 1;



ay(week)        = yes $(week.ord = active_weeks);
d_loadA(t)   = sum [week$ay(week), d_loadA_weeks(t,week)];
E_PV(t)      = sum [week$ay(week), E_PV_weeks(t,week) ];
d_loadB(t)   = sum [week$ay(week), d_loadB_weeks(t,week)];
* d_loadG(t)   = sum [week$ay(week), d_loadG_weeks(t,week)];
xi(t)        = sum [week$ay(week), xi_weeks(t,week)];
c_grid_import(t)= sum [week$ay(week), c_grid_import_weeks(t,week)];
p_grid_export(t)= sum [week$ay(week), p_grid_export_weeks(t,week)];

Solve undergrid using MIP maximizing obj;


*Context
* Writing results:
* =========================================================


*---------Declaration of auxiliary file-------
file TMP_output /tmp_output.txt/
put  TMP_output  putclose
                         'var= obj.l                           rng=welfare!B2                         '/
                         'par= d_loadA                         rng=undergrid!B2                rdim=1 '/
                         'par= d_loadB                         rng=undergrid!D2                rdim=1 '/
                         'par= p_grid_export                   rng=undergrid!F2                rdim=1 '/            
                         'par= c_grid_import                   rng=undergrid!H2                rdim=1 '/
                         'par= xi                              rng=undergrid!J2                rdim=1 '/
                         'par=E_PV                             rng=undergrid!L2                rdim=1 '/
                         'var= d_BESS_charge.l                 rng=undergrid!N2                rdim=1 '/
                         'var= ee_pv.l                         rng=undergrid!P2                rdim=1 '/
                         'var= ee_diesel.l                     rng=undergrid!R2                rdim=1 '/
                         'var= e_BESS_discharge.l              rng=undergrid!T2                rdim=1 '/
                         'var= e_grid_import.l                 rng=undergrid!V2                rdim=1 '/
                         'var= e_grid_export.l                 rng=undergrid!X2                rdim=1 '/
                         'var= e_NSE_A.l                       rng=undergrid!Z2                rdim=1 '/        
                         'var= SOC.l                           rng=undergrid!AB2               rdim=1 '/
                         'var= e_NSE_B.l                       rng=undergrid!AD2               rdim=1 '/
                         'var= r.l                             rng=undergrid!AF2               rdim=1 '/
                         'var= w.l                             rng=undergrid!AH2               rdim=1 '/ 

*First unload to GDX file (occurs during execution phase)

*---------GAMS loading data-------------------
execute_unload "results.gdx"

*=== Now write to variable levels to Excel file from GDX
*---------GAMS loading data-------------------
execute        'gdxxrw.exe results.gdx o="Results_opt_undergrid4sh.xlsx" SQ=n Squeeze=0 EpsOut=0 @tmp_output.txt'

*---------Deleting Auxiliary Files--
execute 'del tmp_output.txt results.gdx';
*$offtext










