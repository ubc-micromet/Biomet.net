function create_1min_data_for_Quest_Release(dateRange,pth_raw,pth_out)

% Creates 1 min averaged data .csv file from 1 min table running on SQM
% logger--for Brian Sinfield, Boreal Laser.

% June 9, 2015 (Nick)

% Revision history:
% 
% Feb 4, 2016 (Zoran)
% - Used the modified create_1min_avg.m file to create data for Bill Hirst.
%  He needed cup_wind and wind_dir at 1min intervals
%

uson = read_bor(fullfile(pth_raw,'u_wind_Avg'));
vson = read_bor(fullfile(pth_raw,'v_wind_Avg'));
%wson = read_bor(fullfile(pth_raw,'w_wind_Avg'));
%Tson = read_bor(fullfile(pth_raw,'Tsonic_Avg'));
co2 = read_bor(fullfile(pth_raw,'CO2_Avg'));
h2o = read_bor(fullfile(pth_raw,'H2O_Avg'));
tv  = read_bor(fullfile(pth_raw,'Clean_tv'),8);

wdir = FR_Sonic_wind_direction([uson'; vson'],'RMY')';
wdir_cor = mod(wdir + 29.4 ,360); % correct for 29.4 degree offset (measured by Bill ~June 22, 2015)

dataOutUS= [sqrt(uson.^2 +vson.^2) wdir_cor ];
dataOutLC= [co2 h2o ];

indextr = find(tv>=dateRange(1) & tv<dateRange(end));
dv_beg=datevec(tv(indextr(1)));
year = dv_beg(1);
doy = tv-datenum(year,1,0);
doyextr = tv(indextr)-datenum(year,1,0);
doy_in_data = unique(floor(doyextr));

for m = 1:length(doy_in_data);
    ind_dd = find(floor(doy)==doy_in_data(m));
    
   % clean_tv contains end of min intervals
   % ind_dd may contain 1st min of day 00:00, which does not belong
   % to month and will not contain 31st 00:60 which does belong to
   % day. 
   ind_dd = ind_dd(2:end);
   ind_dd = [ind_dd;ind_dd(end)+1];
    
    FileName_p = FR_DateToFileName(datenum(year,1,doy(ind_dd(1)),0,30,0));
    fnOut=fullfile(pth_out,['SQ_' FileName_p(1:6) '_Wind_1minavg.csv']);
    fp = fopen(fnOut,'w');
    for kk=1:length(ind_dd)
  
            % export data traces with year, DOY and time of day (hhmm GMT)
%             dt_vec = datevec(tv);
%             year = dt_vec(:,1);
%             doy = floor(tv)-datenum(dt_vec(:,1),1,0);
%             hhmm = dt_vec(:,4)*100+dt_vec(:,5)+dt_vec(:,6)/60;

            dt_str = datestr(tv(ind_dd(kk)),'yyyy/mm/dd HH:MM:SS');
            
            %header1= ['Year,DOY,hhmm,u_wind,v_wind,w_wind,Tsonic,CO2,RevisionDate'];
            %header2= ['UTC,UTC,UTC,m/s,m/s,m/s,degK,ppm in dry air,UTC'];

            % use tags instead of headers

            tagStrUS = '$USDTA';
%            tagStrLC = '$LCDTA';

            %         headerUS= ['yyyy/mm/dd HH:MM:SS,u_wind,v_wind,w_wind,Tsonic'];
            %         headerUSun= ['UTC,m/s,m/s,m/s,degK'];
            %
           
            tic;

            %dv=datevec(now);
            %RevisionDate = sprintf('%4i%02i%02i',dv(1:3));
            % [r,s]=size(dataOutUS);

           
          
            % Format row
            strUS = format_dataline(dataOutUS(ind_dd(kk),:),4);
%            strLC = format_dataline(dataOutLC(ind_dd(kk),:),4);
            fprintf(fp,'%s,%s,%s\n',tagStrUS,dt_str,strUS);
%            fprintf(fp,'%s,%s,%s\n',tagStrLC,dt_str,strLC);
   
            if kk==1, day_str = datestr(tv(ind_dd(kk)),1); end
                    
    end
fclose(fp); % close file after each day
disp(['Exported ' day_str ' to ' fnOut ' in ' num2str(toc) 's']);
end