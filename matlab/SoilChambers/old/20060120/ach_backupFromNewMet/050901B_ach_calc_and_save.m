function ach_calc_and_save(dateRange,SiteFlag)
%mother function which runs chamber flux site computations and saves daily mat files with the results, 'Stats'
%eg. ach_calc_and_save(datenum(2003,8,1):datenum(2003,8,1),'YF');

%Revisions:  
% Mar 16, 2005 - Created using new_calc_and_save as the start point (Zoran)

version_check=ver;
if (str2num(version_check(1).Version(1))~=5) 
    warning off MATLAB:divideByZero;
end;

if ~exist('SiteFlag') | isempty(SiteFlag)
    SiteFlag = fr_current_siteid;
end

configIn  = fr_get_init(SiteFlag,dateRange(1));  % get the ini file
configIn.hhour_ch_ext = '.hy_ch.mat';

for dateIn = floor(dateRange)
    try
        t0 = now;
        [yearX,monthX,dayX ] = datevec(dateIn);

        FileName_p      = FR_DateToFileName(dateIn+.2);
        FileName        = [configIn.hhour_path FileName_p(1:6) configIn.hhour_ch_ext];    % File name for the full set of stats

        hhours = 48;
        currentDate = datenum(yearX,monthX,dayX,0,30:30:30*hhours,0);
        
        if ~isempty(currentDate)
            
            Stats.tvTmp   = currentDate;
            Stats.pBarTmp = 98 .* ones(size(Stats.tvTmp));

            [Stats] = ach_calc(SiteFlag,currentDate(1),Stats,configIn,1);
            % Stats  = yf_calc_module_main(currentDate,SiteFlag);
                        
            save(FileName,'Stats');
            
            Stats.CO2_HF = [];
            Stats.H2O_HF = [];
            Stats.Time_vector_HF = [];
            % use ini file settings to select fields for short mat files
            % [Stats] = make_short_files(configIn,Stats);
            % [Stats(:).Configuration] = deal([]);
            
            FileName        = [configIn.hhour_path FileName_p(1:6) 's' configIn.hhour_ch_ext];    % File name for the full set of stats
            save(FileName,'Stats');
        end
        disp(sprintf('Day: %s. Calc time = %d seconds',datestr(dateIn),(now-t0)*24*60*60));
        
    end  % of Try
end % of for dateIn = 

version_check=ver; 
if (str2num(version_check(1).Version(1))~=5) 
    warning on MATLAB:divideByZero;
end;
