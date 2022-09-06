function ach_calc_and_save(dateRange,SiteFlag)
%Mother function which runs chamber flux site computations and saves daily mat files with the results, 'Stats'
%eg. ach_calc_and_save(datenum(2003,8,1):datenum(2003,8,1),'YF');

%Revisions:
% Dec 2, 2005 - text editing (David)
% Mar 16, 2005 - Created using new_calc_and_save as the start point (Zoran)
warning off;

version_check=ver;
if (str2num(version_check(1).Version(1))~=5) 
    warning off MATLAB:divideByZero;
end;

if ~exist('SiteFlag') | isempty(SiteFlag)
    SiteFlag = fr_current_siteid;
end

for dateIn = floor(dateRange)
    try
        t0 = now;
        [yearX,monthX,dayX ] = datevec(dateIn);

        configIn  = fr_get_init(SiteFlag,dateIn);  % get the ini file

        FileName_p      = FR_DateToFileName(dateIn+.2);
        FileName        = [configIn.hhour_path FileName_p(1:6) configIn.hhour_ch_ext];    % File name for the full set of Stats
        
        hhours = 48;
        currentDate = datenum(yearX,monthX,dayX,0,30:30:30*hhours,0);
        
        if ~isempty(currentDate)
            try
                %try to load clean time and barometric pressure (Pbar) from database
                pth = biomet_path(yearX,SiteFlag,'Clean\ThirdStage\');
                DataDefault.pBarTmp  = read_bor([pth 'barometric_pressure_main'],1,[],[]);
                DataDefault.tvTmp  = read_bor([pth 'clean_tv'],8,[],[]);                
            catch      
                %create default time and barometric pressure (Pbar) if data not available
                DataDefault.tvTmp = currentDate;
                if length(configIn.chamber.Pbar) ~= length(DataDefault.tvTmp)
                    DataDefault.pBarTmp = mean(configIn.chamber.Pbar) .* ones(size(DataDefault.tvTmp));
                else
                    DataDefault.pBarTmp = mean(configIn.chamber.Pbar);
                end
            end
            
            [Stats.Chambers] = ach_calc(SiteFlag,floor(currentDate(1)),DataDefault,configIn);
            
            save(FileName,'Stats');
            
            Stats.Chambers.CO2_HF = [];
            Stats.Chambers.H2O_HF = [];
            Stats.Chambers.Time_vector_HF = [];

            if isfield(Stats.Chambers,'BranchCh_Stats')
                Stats.Chambers.BranchCh_Stats.Temp_HF = [];
                Stats.Chambers.BranchCh_Stats.ClimControl_HF = [];
            end
        
            FileName = [configIn.hhour_path FileName_p(1:6) 's' configIn.hhour_ch_ext];    % File name for the short set of Stats
            save(FileName,'Stats');
        end
        disp(sprintf('Day: %s. Calc time = %d seconds',datestr(dateIn),(now-t0)*24*60*60));
        
    end  % of Try
end % of for dateIn = 

version_check=ver; 
if (str2num(version_check(1).Version(1))~=5) 
    warning on MATLAB:divideByZero;
end;
