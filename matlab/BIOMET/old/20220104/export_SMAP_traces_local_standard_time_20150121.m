function export_mat = export_SMAP_traces_local_standard_time(siteId,year,pth_out,daybuf);

% Nick, May 14, 2014
% number of days buffer from present (currently set to one week)

% Daily export for NASA Soil Moisture Active Passive L4 Tower Flux product

arg_default('daybuf',7);

% read in GMT tv and produce local standard time tv
tic
dv_now = datevec(now);
if year<dv_now(1) % read in two years of data if available
 Years = [year year+1];
else
 Years = [year-1 year];
end
pth=biomet_path('yyyy',siteId);
tv=read_bor(fullfile(pth,'climate\clean','clean_tv'),8,[],Years);

GMTOffset = -6/24;
tv_loc=tv+GMTOffset;
doy = tv_loc-datenum(year,1,0);
dv_loc=datevec(tv_loc);
ind_24 = find(dv_loc(:,4) == 0 & dv_loc(:,5) == 0 );
doy(ind_24) = doy(ind_24) - 1;
dv_loc(ind_24,1)=dv_loc(ind_24-1,1);
dv_loc(ind_24,2)=dv_loc(ind_24-1,2);
dv_loc(ind_24,3)=dv_loc(ind_24-1,3);
dv_loc(ind_24,4)=24;

indOut=find(dv_loc(:,1)==year);

% extract the local standard time year
tv_loc=tv_loc(indOut);
dv_loc=dv_loc(indOut,:);
doy=doy(indOut);

DOY = unique(floor(doy));
DOY_now = now-datenum(year,1,0)-daybuf;

switch upper(siteId)
case 'BS'
   Site     = 112;
   Site_str = 'OBS';
   Stn      = 'SK';
   %GMTOffset = -6/24;
   SubSite_str = 'FlxTwr';
   Rs      = read_bor(fullfile(pth,'climate\clean','radiation_shortwave_downwelling_20m'),[],[],Years,indOut);
   ppfd    = read_bor(fullfile(pth,'climate\clean','Down_PAR_AbvCnpy_25m_UBC'),[],[],Years,indOut);
case 'PA'
   Site     = 000;
   Site_str = 'OA';
   Stn      = 'SK';
   SubSite_str = 'FlxTwr';
   %GMTOffset = -6/24;
   Rs      = read_bor(fullfile(pth,'climate\clean','radiation_shortwave_downwelling_36m_UBC'),[],[],Years,indOut);
   ppfd    = read_bor(fullfile(pth,'climate\clean','Down_PAR_AbvCnpy_37m_UBC'),[],[],Years,indOut);
end

% read in all data

Rn      = read_bor(fullfile(pth,'clean\secondstage','radiation_net_4way_components'),[],[],Years,indOut);  
RnGF    = read_bor(fullfile(pth,'clean\thirdstage','radiation_net_main'),[],[],Years,indOut);
RsGF    = read_bor(fullfile(pth,'clean\thirdstage','global_radiation_main'),[],[],Years,indOut);
ppfdGF  = read_bor(fullfile(pth,'clean\thirdstage','ppfd_downwelling_main'),[],[],Years,indOut);
tair    = read_bor(fullfile(pth,'clean\secondstage','air_temperature_main'),[],[],Years,indOut);
tairGF  = read_bor(fullfile(pth,'clean\thirdstage','air_temperature_main'),[],[],Years,indOut);
vpd     = read_bor(fullfile(pth,'clean\secondstage','vpd_main'),[],[],Years,indOut);
vpdGF   = read_bor(fullfile(pth,'clean\thirdstage','vpd_main'),[],[],Years,indOut);
tsoil   = read_bor(fullfile(pth,'clean\secondstage','soil_temperature_main'),[],[],Years,indOut);
tsoilGF = read_bor(fullfile(pth,'clean\thirdstage','soil_temperature_main'),[],[],Years,indOut);
prec    = read_bor(fullfile(pth,'clean\thirdstage','precipitation_cumulative'),[],[],Years,indOut);
swc    =  read_bor(fullfile(pth,'clean\secondstage','soil_moisture_1'),[],[],Years,indOut);
swcGF    =  read_bor(fullfile(pth,'clean\secondstage','soil_moisture_main'),[],[],Years,indOut);
nee     = read_bor(fullfile(pth,'clean\secondstage','nee_ustar_filtered'),[],[],Years,indOut);
neeGF   = read_bor(fullfile(pth,'clean\thirdstage','nee_filled_with_fits'),[],[],Years,indOut);
gpp     = read_bor(fullfile(pth,'clean\thirdstage','eco_photosynthesis_measured_smap'),[],[],Years,indOut);
gppGF   = read_bor(fullfile(pth,'clean\thirdstage','eco_photosynthesis_filled_with_fits'),[],[],Years,indOut);
Reco    = read_bor(fullfile(pth,'clean\secondstage','eco_respiration_measured_ustar_filtered'),[],[],Years,indOut);
RecoGF  = read_bor(fullfile(pth,'clean\thirdstage','eco_respiration_filled_with_fits'),[],[],Years,indOut);
pbar    = read_bor(fullfile(pth,'clean\thirdstage','barometric_pressure_main'),[],[],Years,indOut);
rdwpot  = read_bor(fullfile(pth,'clean\thirdstage','radiation_downwelling_potential'),[],[],Years,indOut);
snowd   = read_bor(fullfile(pth,'clean\secondstage','snow_depth_main'),[],[],Years,indOut);

Mo = NaN.*ones(length(DOY),1);
Day = NaN.*ones(length(DOY),1);
Rn_f = NaN.*ones(length(DOY),1);
Rn_qc = NaN.*ones(length(DOY),1);
Rs_f = NaN.*ones(length(DOY),1);
Rs_qc = NaN.*ones(length(DOY),1);
ppfd_f = NaN.*ones(length(DOY),1);
ppfd_qc = NaN.*ones(length(DOY),1);
tair_f = NaN.*ones(length(DOY),1);
tair_qc = NaN.*ones(length(DOY),1);
vpd_f = NaN.*ones(length(DOY),1);
vpd_qc = NaN.*ones(length(DOY),1);
tsoil_f = NaN.*ones(length(DOY),1);
tsoil_qc = NaN.*ones(length(DOY),1);
prec_f = NaN.*ones(length(DOY),1);
swc_f = NaN.*ones(length(DOY),1);
swc_qc = NaN.*ones(length(DOY),1);
NEE_f = NaN.*ones(length(DOY),1);
NEE_qc = NaN.*ones(length(DOY),1);
GPP_f = NaN.*ones(length(DOY),1);
GPP_qc = NaN.*ones(length(DOY),1);
Reco_f = NaN.*ones(length(DOY),1);
Reco_qc = NaN.*ones(length(DOY),1);
pbar_f = NaN.*ones(length(DOY),1);
snowD_f = NaN.*ones(length(DOY),1);
CF_e = 1800/10^6;
CF_C = 1800*12e-6;
for i=1:length(DOY)
    ind = find(floor(doy)==DOY(i));
    Mo(i)      = unique(dv_loc(ind,2));
    Day(i)     = unique(dv_loc(ind,3));
    isNight     = rdwpot(ind)==0;
    isDay       = ~isNight;
    ind_cold    = find(tairGF(ind)<0 & tsoilGF(ind)<0 & isDay);
    ind_nig     = find(isNight);
    ind_day     = find(isDay);
    Rn_f(i)    = CF_e*sum(RnGF(ind));
    Rn_qc(i)   = length(find(isnan(Rn(ind))))/length(ind); % fraction of gap-filled data for the day
    Rs_f(i)    = CF_e*sum(RsGF(ind));
    Rs_qc(i)   = length(find(isnan(Rs(ind(ind_day)))))/length(ind_day); % fraction of gap-filled data for the day
    ppfd_f(i)  = CF_e*sum(ppfdGF(ind));
    ppfd_qc(i) = length(find(isnan(ppfd(ind(ind_day)))))/length(ind_day); % fraction of gap-filled data for the day
    tair_f(i)  = mean(tairGF(ind));
    tair_qc(i) = length(find(isnan(tair(ind))))/length(ind); % fraction of gap-filled data for the day
    vpd_f(i)   = mean(vpdGF(ind));
    vpd_qc(i)  = length(find(isnan(vpd(ind))))/length(ind); % fraction of gap-filled data for the day
    tsoil_f(i) = mean(tsoilGF(ind));
    tsoil_qc(i) = length(find(isnan(tsoil(ind))))/length(ind); % fraction of gap-filled data for the day
    prec_f(i)   = prec(ind(end)) - prec(ind(1));
    swc_f(i)    = mean(swcGF(ind));
    swc_qc(i)    = length(find(isnan(swc(ind))))/length(ind); % fraction of gap-filled data for the day
    NEE_f(i)    = CF_C*sum(neeGF(ind));
    NEE_qc(i)   = length(find(isnan(nee(ind))))/length(ind); % fraction of gap-filled data for the day
    GPP_f(i)    = CF_C*sum(gppGF(ind));
    GPP_qc(i)   = length(find(isnan(nee(ind(ind_day)))))/length(ind_day); % fraction of gap-filled data for the day for GEP measured
    Reco_f(i)    = CF_C*sum(RecoGF(ind));
    Reco_qc(i)   = length(find(isnan(Reco(ind(ind_nig)))))/length(ind_nig); % fraction of gap-filled data for the night for R measured
    pbar_f(i)    = mean(pbar(ind));
    snowD_f(i)   = snowd(ind(end));
end

% get rid of spurious forward filling
ind_kill = find(DOY>DOY_now);
Rn_f(ind_kill) = NaN;
Rn_qc(ind_kill) = NaN;
Rs_f(ind_kill) = NaN;
Rs_qc(ind_kill) = NaN;
ppfd_f(ind_kill) = NaN;
ppfd_qc(ind_kill) = NaN;
tair_f(ind_kill) = NaN;
tair_qc(ind_kill) = NaN;
vpd_f(ind_kill) = NaN;
vpd_qc(ind_kill) = NaN;
tsoil_f(ind_kill) = NaN;
tsoil_qc(ind_kill) = NaN;
prec_f(ind_kill) = NaN;
swc_f(ind_kill) = NaN;
NEE_f(ind_kill) = NaN;
NEE_qc(ind_kill) = NaN;
GPP_f(ind_kill) = NaN;
GPP_qc(ind_kill) = NaN;
Reco_f(ind_kill) = NaN;
Reco_qc(ind_kill) = NaN;
pbar_f(ind_kill) = NaN;
snowD_f(ind_kill) = NaN;


% hard code variable names and units
vnam = {'Rn_f' 'Rn_qc' 'Rs_f' 'Rs_qc' 'PAR_f' 'PAR_qc' 'Ta_f' 'Ta_qc' 'VPD_f' 'VPD_qc'...
           'Ts_f' 'Ts_qc' 'PREC' 'SWC' 'NEE_f' 'NEE_qc' 'GPP_f' 'GPP_qc' 'Reco_f' 'Reco_qc' 'PRESS' 'SNOWD'};
unts = {'MJ m^{-2} d^{-1}' 'n/a' 'MJ m^{-2} d^{-1}' 'n/a' 'MJ m^{-2} d^{-1}' 'n/a' 'deg C' 'n/a' 'kPa' 'n/a'...
           'deg C' 'n/a' 'mm' 'm^{3} m^{-3}' 'g C m^{-2} d^{-1}' 'n/a' 'g C m^{-2} d^{-1}' 'n/a' 'g C m^{-2} d^{-1}' 'n/a' 'kPa' 'mm'};

% build header lines

%--------------------------------------------------
% Create the 2 header lines, SMAP preferred format
%--------------------------------------------------
header1 = 'SiteID,Year,Month,Day,DOY,';
header2 = '(n/a),Year,(LST),(LST),(LST),';
for i = 1:length(vnam)
   header1 = [header1  char(vnam(i)) ','];
   % Space is throughn out here, so table can be loaded easily
   ind = find(unts{i} ~= ' ');
   units = unts{i};
   units=units(ind);
   header2 = [header2 '(' units '),'];
end
header1 = [header1 'CertificationCode,RevisionDate'];
header2 = [header2 '(n/a),(yyyymody)'];

CertificationCode = 'PRE';	 % Hard coded for now
dv = datevec(now);
RevisionDate = sprintf('%4i%02i%02i',dv(1:3));


export_mat = [ones(length(DOY),1) * [year] Mo Day DOY Rn_f Rn_qc Rs_f Rs_qc ppfd_f ppfd_qc tair_f tair_qc vpd_f vpd_qc...
              tsoil_f tsoil_qc prec_f swc_f NEE_f NEE_qc GPP_f GPP_qc Reco_f Reco_qc pbar_f snowD_f];
 
          
          
%-------------------------------------------
% Create export filename
%-------------------------------------------
year_str = num2str(year);
file_name = [ Stn '_' upper(siteId)  '_' SubSite_str '_' year_str '-' 'SMAP_localST.csv' ];
          
  %-------------------------------------------
   % Write output file line by line
   %-------------------------------------------
   fp = fopen(fullfile(pth_out,file_name),'w');
   if fp>0
      fprintf(fp,['%s\n'],header1);
      fprintf(fp,['%s\n'],header2);
      for k = 1:length(DOY)
         % Format row
         str = format_dataline(export_mat(k,:),4);
         %fprintf(fp,['%s,%s-%s,%s,%s,%s,%s\n'],Type_str,Stn,Site_str,SubSite_str,str,CertificationCode,RevisionDate);
         fprintf(fp,['%s-%s,%s,%s,%s\n'],Stn,Site_str,str,CertificationCode,RevisionDate);
      end
      fclose(fp);
      disp(['Exported ' file_name ' in ' num2str(toc) 's']);
   else
      disp(['Could not open ' fullfile(pth_out,file_name)]);
   end
        
        
        