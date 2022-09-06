function [fwi,dataOut] = FireWeatherIndex(dataIn)
% FireWeatherIndex calculation
%
% dataIn    - [Month  Day   Temperature(C) RH (%)  Wind (m/s)  Rainfall (mm)]
% dataOut   - [ffmc dmc dc bui isi fwi dsr];
%
% (c) Zoran Nesic           File created:       May 21, 2005
%                           Last modification:  Dec 21, 2011

% Revisions:
%
%   Dec 21, 2011 (Zoran)
%       - added some basic data cleaning (filtering of impossible values).
%   Aug 14, 2005
%       - Created function from a script

%dataIn = textread('fwitest1.txt');
% 
Month = dataIn(:,1);
Tair = dataIn(:,3);
RH = dataIn(:,4);

% Convert the wind speed from m/s to km/hour
WindSpeed = dataIn(:,5)*3600/1000;
Rain = dataIn(:,6);


% ---- Filter out bad data ----
% (basic data cleaning)
%
% Filter impossible values of RH:
RH = basic_cleaning(RH,[0 100]);
% Filter impossible values of Tair:
Tair = basic_cleaning(Tair,[-39 50]);
% Filter impossible values of WindSpeed:
WindSpeed = basic_cleaning(WindSpeed,[-0.0001 150]);
% Filter impossible values of Rain:
Rain = basic_cleaning(Rain,[-0.0001 20]);




el = [6.5 7.5 9 12.8 13.9 13.9 12.4 10.9 9.4 8 7 6];
fl = [-1.6 -1.6 -1.6 0.9 3.8 5.8 6.4 5 2.4 0.4 -1.6 -1.6];


wmo = zeros(length(dataIn),1);
ra = zeros(length(dataIn),1);
ed = zeros(length(dataIn),1);
ew = zeros(length(dataIn),1);
z = zeros(length(dataIn),1);
x = zeros(length(dataIn),1);
wm = zeros(length(dataIn),1);
ffmc = zeros(length(dataIn),1);
dmc = zeros(length(dataIn),1);
dc = zeros(length(dataIn),1);
isi = zeros(length(dataIn),1);
bui = zeros(length(dataIn),1);
fwi = zeros(length(dataIn),1);
dsr = zeros(length(dataIn),1);

ffmc_old = 85;
dmc_old = 6;
dc_old = 15;

for i=1:length(dataIn);

    % FMC calculations
    
    wmo(i) = 147.2*(101-ffmc_old)/(59.5+ffmc_old);
    if Rain(i)>0.5
        ra(i) = Rain(i) - 0.5;
        if wmo(i)>150
            wmo(i) = wmo(i) + 42.5*ra(i) * exp( -100/(251-wmo(i)))...
                        * (1 - exp(-6.93/ra(i))) ...
                        + 0.0015 * (wmo(i)-150)^2 * sqrt(ra(i));
        else
            wmo(i) = wmo(i) + 42.5*ra(i) * exp( -100/(251-wmo(i)))...
                        * (1 - exp(-6.93/ra(i)));
        end
    end
    
    if wmo(i) > 250
        wmo(i) = 250;
    end
    
    ed(i) = 0.942 * RH(i)^0.679 ...
           + (11.0*exp((RH(i)-100.0)/10.0))...
	       + 0.18*(21.1-Tair(i)) * (1.0-1.0/exp(RH(i)*0.115));
    ew(i) =     0.618 * RH(i)^0.753 ...
             + 10.0 * exp((RH(i)-100.0)/10.0) ...
	         +  0.18 * (21.1-Tair(i)) * (1.0-1.0/exp(RH(i)*0.115));
       
    if wmo(i) < ed(i) & wmo(i) < ew(i)
        z(i) = 0.424 * (1.0 - ((100.0-RH(i))/100.0)^1.7)...
	           + 0.0694 * sqrt(WindSpeed(i)) * (1.0- ((100.0-RH(i))/100.0)^8.0);
        x(i) = z(i) * 0.581 * exp(0.0365*Tair(i));
        wm(i) = ew(i) - (ew(i) - wmo(i)) / 10.0^x(i);
    elseif wmo(i) > ed(i)
        z(i)  =   0.424 * (1.0-(RH(i)/100.)^1.7) ...
                + 0.0694 * sqrt(WindSpeed(i)) * (1- (RH(i)/100)^8.0);
        x(i)  = z(i) * 0.581 * exp(0.0365*Tair(i));
        wm(i) = ed(i) + (wmo(i)-ed(i))/10.0^x(i);
    else
        wm(i) = wmo(i);
    end
    ffmc(i) = 59.5 * (250.0 - wm(i)) / (147.2 + wm(i));
    if ffmc(i) > 101.0 
        ffmc(i) = 101.0;
    end
    if ffmc(i) < 0.0
        ffmc(i) = 0 ;
    end
    
    % DMC Calculations

    t(i) = Tair(i);
    if t(i) < -1.1
        t(i) = -1.1;
    end
    rk(i) = 1.894 * ( t(i) + 1.1 ) * ( 100.0 - RH(i) ) * el(Month(i)) * 0.0001;
    if Rain(i) <= 1.5
        pr(i) = dmc_old;
    else
        ra(i) = Rain(i);
        rw(i) = 0.92 * ra(i) - 1.27;
        wmi(i)= 20.0 + 280.0/exp(0.023*dmc_old);
        if dmc_old <= 33
            b(i) = 100.0/(0.5+0.3*dmc_old);
        elseif dmc_old <= 65 
            b(i) = 14.0 - 1.3*log(dmc_old);
        else 
            b(i) = 6.2 * log(dmc_old) - 17.2;
        end
        wmr(i) = wmi(i) + 1000.0 * rw(i) / (48.77 + b(i) * rw(i) );
        pr(i)  = 43.43 * (5.6348-log(wmr(i)-20));
    end
    
    if (pr(i)<0) 
        pr(i)=0 ;
    end
    
    dmc(i) = pr(i) + rk(i);
    
    if dmc(i)<0
        dmc(i)=0;
    end

    % DC calculations
    
    if Tair(i) <- 2.8
        t(i) = -2.8;
    end
    pe(i) = ( 0.36 * (t(i) + 2.8) + fl(Month(i))) / 2.0;
    if pe(i) <0.0 
        pe(i) = 0.0;    %/* the fix for winter negative DC change*/
    end
    
    if Rain(i) <= 2.8
        dr(i) = dc_old;
    else
      ra(i)  = Rain(i);
      rw(i)  = 0.83 * ra(i) - 1.27;
      smi(i) = 800 * exp(-dc_old/400);
      dr(i) = dc_old - 400.0*log(1.0 + 3.937 * rw(i)/smi(i));
      if dr(i)<0
          dr(i) = 0;
      end
    end
    dc(i) = dr(i) + pe(i);
    if dc(i)<0
        dc(i) = 0;
    end
    % isi calculations
    fm(i) = 147.2 * (101.0-ffmc(i)) / (59.5 + ffmc(i));
    sf(i) = 19.115 * exp(-0.1386*fm(i)) * (1.0 + fm(i)^5.31/4.93e07);
    isi(i) = sf(i) * exp(0.05039 * WindSpeed(i));
    % BUI
    if dmc(i) == 0 & dc(i) ==0
        bui(i) = 0;
    else 
        bui(i) = 0.8 * dc(i) * dmc(i) / (dmc(i) + 0.4 * dc(i));
    end
    if bui(i) < dmc(i)
       p(i) = ( dmc(i) - bui(i) )/dmc(i);
       cc(i)   = 0.92 + (0.0114 * dmc(i))^1.7;
       bui(i) = dmc(i) - cc(i) * p(i);
       if  bui(i) <0 
           bui(i) = 0;
       end
    end

    %  FWI and DSR calculation
    
    if bui(i) > 80
        bb(i) = 0.1 * isi(i) * (1000.0/(25.0+108.64/exp(0.023*bui(i))));
    else 
        bb(i)= 0.1 * isi(i) * (0.626 * bui(i)^0.809 + 2.0);
    end
    if bb(i) <= 1
        fwi(i) = bb(i);
    else 
        fwi(i) = exp( 2.72 * (0.434 * log(bb(i)))^0.647 );
    end
    dsr(i) = 0.0272 * fwi(i)^1.77;

    ffmc_old = ffmc(i);
    dmc_old = dmc(i);
    dc_old=dc(i);
    
end

dataOut = [ffmc dmc dc bui isi fwi dsr];

function v_out = basic_cleaning(v_in,v_minmax)
    indBad = (v_in <= v_minmax(1) | v_in > v_minmax(2) | isnan(v_in));
    indGood = find(indBad == 0);
    indBad = find(indBad > 0);
    v_out = v_in;
    v_out(indBad) = interp1(indGood,v_in(indGood),indBad,'linear','extrap');

    
% fid = fopen('fwitest_matlab.txt','wt');
% fprintf(fid,'    Date   Temp     RH   Wind   Rain   FFMC    DMC     DC    BUI    ISI    FWI    DSR\n');
% for i=1:length(dataIn);
%     fprintf(fid,' %3d', [dataIn(i,1:2)]);
%     fprintf(fid,' %6.2f', [dataIn(i,3:6) ffmc(i) dmc(i) dc(i) bui(i) isi(i) fwi(i) dsr(i)]);
%     fprintf(fid,'\n');
% end
% fclose(fid);


% Original C code:
% /*  F32.c  written by BMW @ PNFI
% Modifications
%     jan /94  precision fix etc........bmw
%  Oct/2002
%      to eliminate negative evapouration from DC skit in November
%      thru March.  Change of code to match equations in FTR-33 (1985) 
%      report (change from F32.FOR)
% */
% 
% #include <stdio.h>
% #include <math.h>
% #include <string.h>
% 
% main(int argc, char *argv[])
% {
%   int lmon[13],month,day,err,mon,i;
%   double el[13],fl[13],ffmc_old,dmc_old,dc_old,ffmc,dmc,dc,temp,rh,ws,rain,
% 	 isi,bui,fwi,dsr,t,ra,wmo,ed,ew,z,x,wm,rk,pr,rw,wmi,b,wmr,pe,
% 	 smi,dr,fm,sf,p,cc,bb,sl;
%   FILE *inp,*out;
%   char format1[90],format2[60],a;
%   strcpy(format1,"%2d %2d  %5.1f %4.1f %4.1f %5.1f  ");
%   strcpy(format2,"%5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %6.2f\n");
%   strcat(format1,format2);
%   if(argc==1){
% 	printf(" you must enter a filename as well\n");
% 	printf(" The file should be :\n");
% 	printf(" MONTH   DAY    TEMP(C)    RH(%)    WINDSPEED(km/h)    RAINFALL(mm)\n");
% 	printf(" The command line should look as follows......\n\n");
% 	printf("    F32 filename {starting FFMC} {starting DMC} {starting DC}\n");
% 	printf("       The values in backets are optional\n\n");
% 	exit(9);
%   }
%   inp=fopen(argv[1],"r");
%   for(i=0,a=argv[1][i];i<9 && a!='.' && a!='\0';i++,a=argv[1][i]);
%   if(i!=9) { argv[1][i]='.';argv[1][i+1]='f';argv[1][i+2]='3';argv[1][i+3]='2';
% 		argv[1][i+4]='\0';
%   }
%   out=fopen(argv[1],"w");
%   fprintf(out," Date   Temp  RH  Wind  Rain   FFMC   DMC   DC    BUI   ISI\
%    FWI    DSR\n");
%   if(argc>2){
% 
%       ffmc_old=atof(argv[2]);
%       if(ffmc_old<0 || ffmc_old>101.0){
% 	printf("Invalid starting value for FFMC... using default\n");
% 	ffmc_old=85.0;
%       }
%   }
%   else ffmc_old=85.0;
%   printf("Starting FFMC=%f\n",ffmc_old);
%   if(argc>3){
% 
%       dmc_old=atof(argv[3]);
%       if(dmc_old<0){
% 	printf("Invalid starting value for DMC.... using default\n");
% 	dmc_old=6.0;
%       }
%   }
%   else dmc_old=6.0;
%   printf("Starting DMC=%f\n",dmc_old);
%   if(argc>4){
% 
%       dc_old=atof(argv[4]);
%       if(dc_old<0){
% 	printf("Invalid starting value for DC.... using default\n");
% 	dc_old=15.0;
%       }
%   }
%   else dc_old=15.0;
%   printf("Starting DC=%f\n",dc_old);
% 
%   /*   must get in the array values as well   */
%   lmon[1]=31;lmon[2]=28;lmon[3]=31;lmon[4]=30;lmon[5]=31;lmon[6]=30;
%   lmon[7]=31;lmon[8]=31;lmon[9]=30;lmon[10]=31;lmon[11]=30;lmon[12]=31;
%   el[1]=6.5;el[2]=7.5;el[3]=9.0;el[4]=12.8;el[5]=13.9;el[6]=13.9;
%   el[7]=12.4;el[8]=10.9;el[9]=9.4;el[10]=8.0;el[11]=7.0;el[12]=6.0;
%   fl[1]=-1.6;fl[2]=-1.6;fl[3]=-1.6;fl[4]=0.9;fl[5]=3.8;fl[6]=5.8;
%   fl[7]=6.4;fl[8]=5.0;fl[9]=2.4;fl[10]=0.4;fl[11]=-1.6;fl[12]=-1.6;
% 
%   err=fscanf(inp,"%d%d%lf%lf%lf%lf",&mon,&day,&temp,&rh,&ws,&rain);
%   while(!feof(inp) && err>0)
%    {
%     /* FFMC part */
%     wmo=147.2*(101-ffmc_old)/(59.5+ffmc_old);
%     if(rain>0.5)
%      { ra=rain-0.5;
%        if(wmo>150) wmo+= 42.5*ra*exp(-100.0/(251-wmo))*(1.0-exp(-6.93/ra))+
% 			    0.0015*(wmo-150)*(wmo-150)*sqrt(ra);
%        else wmo+=42.5*ra*exp(-100.0/(251-wmo))*(1.0-exp(-6.93/ra));
%      }
%     if(wmo>250)wmo=250;
%     ed=0.942*pow(rh,0.679)+(11.0*exp((rh-100.0)/10.0))+
% 	       0.18*(21.1-temp)*(1.0-1.0/exp(rh*0.115));
%     ew=0.618*pow(rh,0.753)+(10.0*exp((rh-100.0)/10.0))+
% 	       0.18*(21.1-temp)*(1.0-1.0/exp(rh*0.115));
%     if(wmo<ed && wmo<ew)
%      { z = 0.424*(1.0-pow(((100.0-rh)/100.0),1.7))+
% 	      0.0694*sqrt(ws)*(1.0-pow((100.0-rh)/100.0,8.0));
%        x = z*0.581*exp(0.0365*temp);
%        wm = ew-(ew-wmo)/pow(10.0, x);
%      }
%     else if(wmo>ed)
%      {
%        z = 0.424*(1.0-pow((rh/100.),1.7))+0.0694*sqrt(ws)*(1-pow(rh/100,8.0));
%        x = z*0.581*exp(0.0365*temp);
%        wm = ed+(wmo-ed)/pow(10.0,x);
%      }
%     else wm = wmo;
%     ffmc = 59.5*(250.0-wm)/(147.2+wm);
%     if(ffmc > 101.0)ffmc = 101.0;
%     if(ffmc < 0.0) ffmc = 0 ;
% /*  now the DMC part  */
%     t=temp;
%     if(temp<-1.1) t=-1.1;
%     rk = 1.894*(t+1.1)*(100.0-rh)*el[mon]*0.0001;
%     if(rain<=1.5) pr = dmc_old;
%     else
%      {
%       ra=rain;
%       rw=0.92*ra-1.27;
%       wmi=20.0+280.0/exp(0.023*dmc_old);
%       if(dmc_old<=33) b = 100.0/(0.5+0.3*dmc_old);
%       else if(dmc_old<=65) b = 14.0-1.3*log(dmc_old);
%       else b= 6.2*log(dmc_old)-17.2;
%       wmr=wmi+1000.0*rw/(48.77+b*rw);
%       pr = 43.43*(5.6348-log(wmr-20));
%      }
%     if (pr<0) pr=0 ;
%     dmc = pr + rk;
%     if (dmc<0)dmc=0;
% /*   now onto the DC part */
%     if(temp<-2.8) t=-2.8;
%     pe = (.36*(t+2.8) + fl[mon])/2.0;
%     if (pe<0.0) pe = 0.0;    /* the fix for winter negative DC change*/
%     if(rain<=2.8) dr = dc_old;
%     else
%      {
%       ra=rain;
%       rw = 0.83*ra - 1.27;
%       smi = 800*exp(-dc_old/400);
%       dr = dc_old - 400.0*log(1.0+3.937*rw/smi);
%       if(dr<0) dr = 0;
%      }
%     dc = dr + pe;
%     if(dc<0) dc=0;
% /*  now the isi */
%     fm = 147.2*(101.0-ffmc)/(59.5+ffmc);
%     sf = 19.115*exp(-0.1386*fm)*(1.0+pow(fm,5.31)/4.93e07);
%     isi = sf*exp(0.05039*ws);
% /* the BUI*/
%     if(dmc==0 && dc==0) bui=0;
%     else bui = 0.8*dc*dmc/(dmc+0.4*dc);
%     if(bui<dmc)
%      { p=(dmc-bui)/dmc;
%        cc = 0.92+pow( (0.0114*dmc),1.7);
%        bui = dmc - cc*p;
%        if(bui<0) bui=0;
%      }
% /* FWI and DSR*/
%     if(bui>80)bb= 0.1*isi*(1000.0/(25.0+108.64/exp(0.023*bui)));
%     else bb= 0.1*isi*(0.626*pow(bui,0.809)+2.0);
%     if (bb<=1)fwi=bb;
%     else fwi=exp(2.72*pow(0.434*log(bb),0.647) );
%     dsr = 0.0272*pow(fwi,1.77);
% 
%     fprintf(out,format1,mon,day,temp,rh,ws,rain,ffmc,dmc,dc,bui,isi,
%        fwi,dsr);
%     ffmc_old=ffmc; dmc_old=dmc;  dc_old=dc;
%     err=fscanf(inp,"%d%d%lf%lf%lf%lf",&mon,&day,&temp,&rh,&ws,&rain);
%    }
%   printf("\n\n\nThe output is in the file %s \n\n",argv[1]);
%   fclose(inp);
%   fclose(out);
% }
