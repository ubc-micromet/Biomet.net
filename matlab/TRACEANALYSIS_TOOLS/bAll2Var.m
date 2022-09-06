% 	bAll2Var 
%  bAll2Var strips specified variables from the BERMS All files, with a time stamp.
%  Program by Alan Barr, written 2 Jan 2001.
%  Revised by kai* July 6, 2001 for UBC purposes

function [t,x]=bAll2Var(Site,iYr1,iMo1,iYr2,iMo2,fQC,iVars);  

%	*********************************************************************************************
%	*********************************************************************************************

%	DataAll elements (by column), in 30 Min bRaw2All/bAll2Spd SiMYrEOM.Spd Output Table 777 

	naRecsPerDay=48; 

	iaTableID=1; iaYr=2; iaDOY=3; iaHrMnUTC=4; iaStnID=5; 

	iaRnBm=6; iaRsdTp=7; iaRsdEpp=8; iaRsuBm=9;
	iaRldTp1=10; iaRldTp2=11; iaTbRld=12; iaTdRld=13; 
	iaRluBm1=14; iaRluBm2=15; iaTbRlu=16; iaTdRlu=17; 
	iaRpdTp=18; iaRpuBm=19; iaRpdUS1=20; iaRpdUS2=21; iaRpdUS3=22; 

	iaHMPTVnt=23; iaHMPT1=24; iaHMPT2=25; iaHMPT3=26; iaHMPT4=27; iaHMPT5=28; 
	iaHMPRHVnt=29; iaHMPRH1=30; iaHMPRH2=31; iaHMPRH3=32; iaHMPRH4=33; iaHMPRH5=34; 
	iaTatc=35; iadTa3tc=36; iaTatcVnt=37; iaTaPRTVnt=38;

	iaTs11=39; iaTs12=40; iaTs13=41; iaTs14=42; iaTs15=43; iaTs16=44; 
	iaTs21=45; iaTs22=46; iaTs23=47; iaTs24=48; iaTs25=49; iaTs26=50; 
	iaTsG1=51; iaTsG2=52; 
	iaTbole1=53; iaTbole2=54; iaTbole3=55; iaTbole4=56; iaTbole5=57; iaTbole6=58; 
	iaG1=59; iaG2=60; iaG3=61; iaG4=62; 

	iaPressure=63; iaSnowDpth=64; iaTaUDG=65; iazWater=66; 
	iaPcpTBRG=67; iaPcpBel=68; iaPcpBel3=69; 
	iaWndSpdBel=70; iaWndSpdBel3=71; 
	iaWndSpdTp=72; iaWndDirTp=73; iaWndDirTpSD=74; 
  	iaTAnalogMet1=75; iaTAnalogMet2=76; iaTAnalogPcp=77; iaTAnalogSoil=78; 
	iaVBatteryMet=79; iaVBatterySoil=80; iaVBatteryPcp=81; 
  
%	Derived variables.

	iaRsdTOA=82; iaRldTpC=83; iaRluBmC=84; 
	iaRnAdj=85; iaRn4Way=86; 
	iaPcpCumBel=87; iaPcpCumBel3=88; 
	
%	*******************************************************************
%	Create an x matrix for the specified variables, with a t time stamp.
%	*******************************************************************

	% kai* July 6, 2001
    fr_set_site(Site,'local');
    [hh,pth] = fr_get_local_path;
    ind_slash = find(pth == '\');
    DirAll=[pth(1:ind_slash(end-1)) 'berms\']; 
    switch upper(Site)
    case 'PA'
        Site = 'OA';
    case 'BS'
        Site = 'OB';
    case 'JP'
        Site = 'OJ';
    end
    % end kai*

   t=[]; xAll=[]; aVars=[]; aUnits=[]; nAll=0; 

	iSerMo1=(iYr1-1)*12+iMo1; iSerMo2=(iYr2-1)*12+iMo2; 
	for iSerMo=iSerMo1:iSerMo2; 

		iYr=ceil(iSerMo/12); iMo=mod(iSerMo,12); if iMo==0; iMo=12; end; 
  
		iEOM=eomday(iYr,iMo); naRecsMo=iEOM*naRecsPerDay; 
		cDOY=num2str(datenum(iYr,iMo,iEOM)-datenum(iYr,1,1)+1); 
		if length(cDOY)==2; cDOY=strcat('0',cDOY); end; 
      cYr=num2str(iYr); 
      
		if fQC==0; 
				naVars=81; FileAll=strcat(Site(1:2),'m',cYr(3:4),cDOY,'.All'); 
			else; 
				naVars=88; FileAll=strcat(Site(1:2),'m',cYr(3:4),cDOY,'.Al',num2str(fQC)); 
		end; 
   
		NamesAll=cell(size(1:naVars)); VarsAll=cell(size(1:naVars)); UnitsAll=cell(size(1:naVars));
         
      fid=fopen(strcat(DirAll,FileAll));  
      %sprintf('%s %5.0f \n',strcat(DirAll,FileAll),fid) 
		if (fid)~=-1;
				aVars=fgets(fid); aUnits=fgets(fid); 
				xTmp=fscanf(fid,'%f',[naVars,naRecsMo]); xTmp=xTmp'; 
				fclose(fid);
         else; 
				xTmp=ones(naRecsMo,naVars)*NaN; tTmp=ones(naRecsMo,1)*NaN;
		end;
      xAll(nAll+1:nAll+naRecsMo,:)=xTmp; 
      nAll=nAll+naRecsMo;
      
   end;
   
   HrAll=floor(xAll(:,iaHrMnUTC,1)/100); MnAll=mod(xAll(:,iaHrMnUTC,1),100);
   t=datenum(xAll(:,iaYr,1),1,1) + (xAll(:,iaDOY,1)-1) + HrAll/24 + MnAll/24/60;
   
   x=xAll(:,iVars); 

	Missing=-999; x(find(x==Missing))=NaN; 
   xLimitN=-999; x(find(x<xLimitN))=NaN; 
   
	