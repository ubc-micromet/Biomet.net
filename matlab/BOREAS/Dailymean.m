%this program calculates dailymean value of Fc,LE,H,Rn,Ta,RH,Precipitation,
%SolarR, PPFD, Ts2cm, and Ts50cm.
%
%(C)Bill Chen											File created:  Jun. 1, 1998
%															Last modified: Jun. 1, 1998
%
%Revision:
global DATA_PATH_BILL_1

days = 1;

% --- get time ---

load([DATA_PATH_BILL_1 '1994\DecDOY_94']);
load([DATA_PATH_BILL_1 '1996\DecDOY_96']);
load([DATA_PATH_BILL_1 '1997\DecDOY_97']);

% --- get air e (kPa) ---

load([DATA_PATH_BILL_1 '1994\e94']);
load([DATA_PATH_BILL_1 '1996\e96']);
load([DATA_PATH_BILL_1 '1997\e97']);

[esum94,emean94,TimeX94] = integz1(t_94(~isnan(e94)),e94(~isnan(e94)),1:365,days);    
[esum96,emean96,TimeX96] = integz1(t_96(~isnan(e96)),e96(~isnan(e96)),1:366,days);    
[esum97,emean97,TimeX97] = integz1(t_97(~isnan(e97)),e97(~isnan(e97)),1:365,days);    

eMean94O =  emean94'; 
eMean96O	=	emean96'; 
eMean97O	=	emean97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\e94DM_O.txt' eMean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\e96DM_O.txt' eMean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\e97DM_O.txt' eMean97O -ascii

% --- get soil temperature at 2cm and 50cm depth (oC) ---

% at 50 cm depth

load([DATA_PATH_BILL_1 '1994\ST50CM94F']);
load([DATA_PATH_BILL_1 '1996\ST50CM96F']);
load([DATA_PATH_BILL_1 '1997\ST50CM97F']);

Ts5094 = ST50CM94F;
Ts5096 = ST50CM96F;
Ts5097 = ST50CM97F;

clear ST50CM94F ST50CM96F ST50CM97F

[Ts50sum94,Ts50mean94,TimeX94] = integz1(t_94(~isnan(Ts5094)),Ts5094(~isnan(Ts5094)),1:365,days);    
[Ts50sum96,Ts50mean96,TimeX96] = integz1(t_96(~isnan(Ts5096)),Ts5096(~isnan(Ts5096)),1:366,days);    
[Ts50sum97,Ts50mean97,TimeX97] = integz1(t_97(~isnan(Ts5097)),Ts5097(~isnan(Ts5097)),1:365,days);    

Ts50Mean94O =  Ts50mean94'; 
Ts50Mean96O	=	Ts50mean96'; 
Ts50Mean97O	=	Ts50mean97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\Ts50CM94DM_O.txt' Ts50Mean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Ts50CM96DM_O.txt' Ts50Mean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Ts50CM97DM_O.txt' Ts50Mean97O -ascii

% at 2 cm depth
load([DATA_PATH_BILL_1 '1994\ST2CM94F']);
load([DATA_PATH_BILL_1 '1996\ST2CM96F']);
load([DATA_PATH_BILL_1 '1997\ST2CM97F']);

Ts294 = ST2CM94F;
Ts296 = ST2CM96F;
Ts297 = ST2CM97F;

clear ST2CM94F ST2CM96F ST2CM97F

[Ts2sum94,Ts2mean94,TimeX94] = integz1(t_94(~isnan(Ts294)),Ts294(~isnan(Ts294)),1:365,days);    
[Ts2sum96,Ts2mean96,TimeX96] = integz1(t_96(~isnan(Ts296)),Ts296(~isnan(Ts296)),1:366,days);    
[Ts2sum97,Ts2mean97,TimeX97] = integz1(t_97(~isnan(Ts297)),Ts297(~isnan(Ts297)),1:365,days);    

Ts2Mean94O =  Ts2mean94'; 
Ts2Mean96O	=	Ts2mean96'; 
Ts2Mean97O	=	Ts2mean97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\Ts2CM94DM_O.txt' Ts2Mean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Ts2CM96DM_O.txt' Ts2Mean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Ts2CM97DM_O.txt' Ts2Mean97O -ascii


% --- get PPFD (umol m-2 s-1)

load([DATA_PATH_BILL_1 '1994\PPFD36m_D_94']);
load([DATA_PATH_BILL_1 '1996\PPFD36m_D_96']);
load([DATA_PATH_BILL_1 '1997\PPFD36m_D_97']);

PPFD94 = PPFD36m_D_94;
PPFD96 = PPFD36m_D_96;
PPFD97 = PPFD36m_D_97;

clear PPFD36m_D_94 PPFD36m_D_96 PPFD36m_D_97

[PPFDsum94,PPFDmean94,TimeX94] = integz1(t_94(~isnan(PPFD94)),PPFD94(~isnan(PPFD94)),1:365,days);    
[PPFDsum96,PPFDmean96,TimeX96] = integz1(t_96(~isnan(PPFD96)),PPFD96(~isnan(PPFD96)),1:366,days);    
[PPFDsum97,PPFDmean97,TimeX97] = integz1(t_97(~isnan(PPFD97)),PPFD97(~isnan(PPFD97)),1:365,days);    

PPFDMean94O =  PPFDmean94'; 
PPFDMean96O	=	PPFDmean96'; 
PPFDMean97O	=	PPFDmean97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\PPFD94DM_O.txt' PPFDMean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\PPFD96DM_O.txt' PPFDMean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\PPFD97DM_O.txt' PPFDMean97O -ascii

% --- get Solar (W m-2) ---

load([DATA_PATH_BILL_1 '1994\SolarR39m_94']);
load([DATA_PATH_BILL_1 '1996\SolarR39m_96']);
load([DATA_PATH_BILL_1 '1997\SolarR39m_97']);

S94 = SolarR39m_94;
S96 = SolarR39m_96;
S97 = SolarR39m_97;

clear SolarR39m_94 SolarR39m_96 SolarR39m_97

[Ssum94,Smean94,TimeX94] = integz1(t_94(~isnan(S94)),S94(~isnan(S94)),1:365,days);    
[Ssum96,Smean96,TimeX96] = integz1(t_96(~isnan(S96)),S96(~isnan(S96)),1:366,days);    
[Ssum97,Smean97,TimeX97] = integz1(t_97(~isnan(S97)),S97(~isnan(S97)),1:365,days);    

SMean94O =  Smean94'; 
SMean96O	=	Smean96'; 
SMean97O	=	Smean97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\S94DM_O.txt' SMean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\S96DM_O.txt' SMean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\S97DM_O.txt' SMean97O -ascii


% --- get H (W m-2) ---

load([DATA_PATH_BILL_1 '1994\SHF_94']);
load([DATA_PATH_BILL_1 '1996\SHF_96']);
load([DATA_PATH_BILL_1 '1997\SHF_97']);

H94 = SHF_94;
H96 = SHF_96;
H97 = SH_97;

clear SHF_94 SHF_96 SHF_97

[Hsum94,Hmean94,TimeX94] = integz1(t_94(~isnan(H94)),H94(~isnan(H94)),1:365,days);    
[Hsum96,Hmean96,TimeX96] = integz1(t_96(~isnan(H96)),H96(~isnan(H96)),1:366,days);    
[Hsum97,Hmean97,TimeX97] = integz1(t_97(~isnan(H97)),H97(~isnan(H97)),1:365,days);    

HMean94O =  Hmean94'; 
HMean96O	=	Hmean96'; 
HMean97O	=	Hmean97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\H94DM_O.txt' HMean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\H96DM_O.txt' HMean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\H97DM_O.txt' HMean97O -ascii

% --- get precipitation ---

load([DATA_PATH_BILL_1 '1994\rainfall94']);
load([DATA_PATH_BILL_1 '1996\rainfall96']);
load([DATA_PATH_BILL_1 '1997\rainfall97']);

rain94 = rainfall94;
rain96 = rainfall96;
rain97 = rainfall97;

clear rainfall94 rainfall96 rainfall97

[rainsum94,rainmean94,TimeX94] = integz1(t_94(~isnan(rain94)),rain94(~isnan(rain94)),1:365,days);    
[rainsum96,rainmean96,TimeX96] = integz1(t_96(~isnan(rain96)),rain96(~isnan(rain96)),1:366,days);    
[rainsum97,rainmean97,TimeX97] = integz1(t_97(~isnan(rain97)),rain97(~isnan(rain97)),1:365,days);    

rainSum94O  =  rainsum94'; 
rainSum96O	=	rainsum96'; 
rainSum97O	=	rainsum97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\rain94DS_O.txt' rainSum94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\rain96DS_O.txt' rainSum96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\rain97DS_O.txt' rainSum97O -ascii

% --- get Rn (W m-2) ---

load([DATA_PATH_BILL_1 '1994\Rn94M']);
load([DATA_PATH_BILL_1 '1996\Rn96M']);
load([DATA_PATH_BILL_1 '1997\Rn97M']);
load([DATA_PATH_BILL_1 '1996\Rn96C']);
load([DATA_PATH_BILL_1 '1997\Rn97C']);

ind = find(~isnan(Rn96M)&~isnan(Rn96C));
[p] = polyfit(Rn96M(ind),Rn96C(ind),1);
ind = find(~isnan(Rn96M)&isnan(Rn96C));
Rn96C(ind) = polyval(p,Rn96M(ind));

ind = find(~isnan(Rn97M)&~isnan(Rn97C));
[p] = polyfit(Rn97M(ind),Rn97C(ind),1);
ind = find(~isnan(Rn97M)&isnan(Rn97C));
Rn97C(ind) = polyval(p,Rn97M(ind));

[Rnsum94,Rnmean94,TimeX94] = integz1(t_94(~isnan(Rn94M)),Rn94M(~isnan(Rn94M)),1:365,days);    
[Rnsum96,Rnmean96,TimeX96] = integz1(t_96(~isnan(Rn96C)),Rn96C(~isnan(Rn96C)),1:366,days);    
[Rnsum97,Rnmean97,TimeX97] = integz1(t_97(~isnan(Rn97C)),Rn97C(~isnan(Rn97C)),1:365,days);    

RnMean94O   =  Rnmean94'; 
RnMean96O	=	Rnmean96'; 
RnMean97O	=	Rnmean97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\Rn94DM_O.txt' RnMean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Rn96DM_O.txt' RnMean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Rn97DM_O.txt' RnMean97O -ascii

% --- get Air Temperature (oC) ---

load([DATA_PATH_BILL_1 '1994\Tair39m_94']);
load([DATA_PATH_BILL_1 '1996\Tair39m_96']);
load([DATA_PATH_BILL_1 '1997\Tair39m_97']);

Ta94 = Tair39m_94;
Ta96 = Tair39m_96;
Ta97 = Tair39m_97;

clear Tair39m_94 Tair39m_96 Tair39m_97

[Tasum94,Tamean94,TimeX94] = integz1(t_94(~isnan(Ta94)),Ta94(~isnan(Ta94)),1:365,days);    
[Tasum96,Tamean96,TimeX96] = integz1(t_96(~isnan(Ta96)),Ta96(~isnan(Ta96)),1:366,days);    
[Tasum97,Tamean97,TimeX97] = integz1(t_97(~isnan(Ta97)),Ta97(~isnan(Ta97)),1:365,days);    

TaMean94O   =  Tamean94'; 
TaMean96O	=	Tamean96'; 
TaMean97O	=	Tamean97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\Ta94DM_O.txt' TaMean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Ta96DM_O.txt' TaMean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Ta97DM_O.txt' TaMean97O -ascii


% --- get LE flux (W m-2) ---

load([DATA_PATH_BILL_1 '1994\LE_94']);
load([DATA_PATH_BILL_1 '1996\LE_96']);
load([DATA_PATH_BILL_1 '1997\LE_97']);

LE94 = LE_94;
LE96 = LE_96;
LE97 = LE_97;

clear LE_94 LE_96 LE_97

[LEsum94,LEmean94,TimeX94] = integz1(t_94(~isnan(LE94)),LE94(~isnan(LE94)),1:365,days);    
[LEsum96,LEmean96,TimeX96] = integz1(t_96(~isnan(LE96)),LE96(~isnan(LE96)),1:366,days);    
[LEsum97,LEmean97,TimeX97] = integz1(t_97(~isnan(LE97)),LE97(~isnan(LE97)),1:365,days);    

LEMean94O   =  LEmean94'; 
LEMean96O	=	LEmean96'; 
LEMean97O	=	LEmean97'; 

save 'c:\bill\ameriflux\conferences\montana\paoa\data\LE94DM_O.txt' LEMean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\LE96DM_O.txt' LEMean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\LE97DM_O.txt' LEMean97O -ascii

% --- get CO2 flux (umol m-2 s-1) ---

%Original Data
%=============

load([DATA_PATH_BILL_1 '1994\Fco2_39m_94']);
load([DATA_PATH_BILL_1 '1996\Fco2_39m_96']);
load([DATA_PATH_BILL_1 '1997\Fco2_39m_97']);

Fc94 = 1000/44*Fco2_39m_94;	%unit convert from mg/m2/s to umol/m2/s
Fc96 = 1000/44*Fco2_39m_96;	%unit convert from mg/m2/s to umol/m2/s
Fc97 = 1000/44*Fco2_39m_97;	%unit convert from mg/m2/s to umol/m2/s

[Fcsum94,Fcmean94,TimeX94] = integz1(t_94(~isnan(Fc94)),Fc94(~isnan(Fc94)),1:365,days);    
[Fcsum96,Fcmean96,TimeX96] = integz1(t_96(~isnan(Fc96)),Fc96(~isnan(Fc96)),1:366,days);    
[Fcsum97,Fcmean97,TimeX97] = integz1(t_97(~isnan(Fc97)),Fc97(~isnan(Fc97)),1:365,days);    

FcMean94O =  Fcmean94'; TimeX94 = TimeX94';
FcMean96O	=	Fcmean96'; TimeX96 = TimeX96';
FcMean97O	=	Fcmean97'; TimeX97 = TimeX97';

save 'c:\bill\ameriflux\conferences\montana\paoa\data\TimeX94.txt' TimeX94 -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\TimeX96.txt' TimeX96 -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\TimeX97.txt' TimeX97 -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Fc94DM_O.txt' FcMean94O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Fc96DM_O.txt' FcMean96O -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Fc97DM_O.txt' FcMean97O -ascii

%storage model
%=============
load([DATA_PATH_BILL_1 '1994\Fc94S']); %unit: umol m-2 -1
load([DATA_PATH_BILL_1 '1996\Fc96S']); %unit: umol m-2 -1
load([DATA_PATH_BILL_1 '1997\Fc97S']); %unit: umol m-2 -1

[Fcsum94,Fcmean94,TimeX94] = integz1(t_94(~isnan(Fc94S)),Fc94S(~isnan(Fc94S)),1:365,days);    
[Fcsum96,Fcmean96,TimeX96] = integz1(t_96(~isnan(Fc96S)),Fc96S(~isnan(Fc96S)),1:366,days);    
[Fcsum97,Fcmean97,TimeX97] = integz1(t_97(~isnan(Fc97S)),Fc97S(~isnan(Fc97S)),1:365,days);    

FcMean94S  	=  Fcmean94'; TimeX94 = TimeX94';
FcMean96S	=	Fcmean96'; TimeX96 = TimeX96';
FcMean97S	=	Fcmean97'; TimeX97 = TimeX97';

save 'c:\bill\ameriflux\conferences\montana\paoa\data\Fc94DM_S.txt' FcMean94S -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Fc96DM_S.txt' FcMean96S -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Fc97DM_S.txt' FcMean97S -ascii

%high wind model
%===============
load([DATA_PATH_BILL_1 '1994\Fc94W']); %unit: umol m-2 -1
load([DATA_PATH_BILL_1 '1996\Fc96W']); %unit: umol m-2 -1
load([DATA_PATH_BILL_1 '1997\Fc97W']); %unit: umol m-2 -1

[Fcsum94,Fcmean94,TimeX94] = integz1(t_94(~isnan(Fc94W)),Fc94W(~isnan(Fc94W)),1:365,days);    
[Fcsum96,Fcmean96,TimeX96] = integz1(t_96(~isnan(Fc96W)),Fc96W(~isnan(Fc96W)),1:366,days);    
[Fcsum97,Fcmean97,TimeX97] = integz1(t_97(~isnan(Fc97W)),Fc97W(~isnan(Fc97W)),1:365,days);    

FcMean94W = Fcmean94'; TimeX94 = TimeX94';
FcMean96W =	Fcmean96'; TimeX96 = TimeX96';
FcMean97W =	Fcmean97'; TimeX97 = TimeX97';

save 'c:\bill\ameriflux\conferences\montana\paoa\data\Fc94DM_W.txt' FcMean94W -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Fc96DM_W.txt' FcMean96W -ascii
save 'c:\bill\ameriflux\conferences\montana\paoa\data\Fc97DM_W.txt' FcMean97W -ascii
