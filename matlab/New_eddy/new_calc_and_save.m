function new_calc_and_save(dateRange,SiteFlag,LoadFlag)
%mother function which runs eddy flux site computations and saves daily mat files with the results, 'Stats'
%eg. new_calc_and_save(datenum(2003,8,1):datenum(2003,8,1),'YF');
% 
% To calc only half-hours not present in an already existing file set LoadFlag = 1. 
% Default is 0. Example:
% new_calc_and_save(datenum(2004,5,28),'BS',1);

%Revisions:  
%
% May 15, 2020 (Zoran)
%   - syntax changes to deal with Matlab 2020=>
% Apr 9, 2018 (Zoran)
%   - improved try-catch statements so the program reports correctly where
%     the errors happen
% May 28, 2008 (Zoran)
%   - joined two versions of this file (MPB_Network and Biomet.net). 
% Apr 30, 2007
%   - added an option that enables user to skip short file creation.
% May 28, 2004 - kai*: Added LoadFlag
%Aug 20, 2003 - E. Humphreys:  added local function to process short files using configIn information
% Sep 01, 2004 - Schwalm: Added version check to disable moot warning messages in MatLab 5.3

%warning off MATLAB:divideByZero


if ~exist('SiteFlag','var') | isempty(SiteFlag) %#ok<*OR2>
    SiteFlag = fr_current_siteID;
end

if ~exist('LoadFlag','var') | isempty(LoadFlag)
    LoadFlag = 0;
end

configIn  = fr_get_init(SiteFlag,dateRange(1));  % get the ini file

for dateIn = floor(dateRange)
    try
        t0 = now;
        [yearX,monthX,dayX ] = datevec(dateIn);

        FileName_p      = fr_DateToFileName(dateIn+.2);
        FileName        = [configIn.hhour_path FileName_p(1:6) configIn.hhour_ext];    % File name for the full set of stats

        hhours = 48;
        currentDate = datenum(yearX,monthX,dayX,0,30:30:30*hhours,0);
        if LoadFlag == 1 
            % Find and load existing file and find uncalculated hhours
            if exist(FileName,'file') == 2
                Stats_old = load(FileName);
                TimeVector = get_stats_field(Stats_old.Stats,'TimeVector');
                test_var = get_stats_field(Stats_old.Stats,'Instrument(1).Avg(1)');
                ind_calc = find(isnan(test_var) & TimeVector<=fr_round_hhour(now,3));
                currentDate = currentDate(ind_calc);
            else
                LoadFlag = 0;
            end
        end
        
        if ~isempty(currentDate)
            Stats  = yf_calc_module_main(currentDate,SiteFlag);
            
            if LoadFlag == 1
                % Merge loaded and calculated stats files
                Stats_new = Stats_old.Stats;
                Stats_new(ind_calc) = Stats;
                Stats = Stats_new;
            end
            
            try
                save(FileName,'Stats');
            catch
                fprintf('Error saving file: %s\n',FileName);
            end
            
            try
                %use ini file settings to select fields for short mat files
                [Stats] = make_short_files(configIn,Stats);
                %[Stats(:).Configuration] = deal([]);

                if ~isempty(Stats)
                    FileName        = [configIn.hhour_path FileName_p(1:6) 's' configIn.hhour_ext];    % File name for the full set of stats
                    save(FileName,'Stats');
                end
            catch
                 fprintf('Error saving short file: %s\n',FileName);
            end
        end
        fprintf('Day: %s. Calc time = %d seconds\n',datestr(dateIn),(now-t0)*24*60*60);
    catch
        fprintf('Unknown error in new_calc_and_save.\n');
    end  % of Try
end % of for dateIn = 



 %-----------------------------------------------------------------------------------------------------
 %function to create short files
 function [st] = make_short_files(configIn,st)
 
 if isfield(configIn,'Shortfiles') & isfield(configIn.Shortfiles,'Remove') ...
          & isfield(configIn.Shortfiles.Remove(1),'System') & ~isempty(configIn.Shortfiles.Remove(1).System) %#ok<*AND2>
     for i = 1:length(configIn.Shortfiles.Remove)
        for j = 1:length(configIn.Shortfiles.Remove(i).Fields)
           for k = 1:length(st) 
              try  %#ok<*TRYNC>
                 for m = 1:length(getfield(st(k),char(configIn.Shortfiles.Remove(i).System)))
                    st(k) = setfield(st(k),char(configIn.Shortfiles.Remove(i).System),{m},...
                       char(configIn.Shortfiles.Remove(i).Fields(j)),[]); 
                 end
              end
           end
        end
        
        try 
            if isfield(configIn.Shortfiles.Remove(i),'ProcessData') ...
              & ~isempty(configIn.Shortfiles.Remove(i).ProcessData)
                for l=1:length(configIn.Shortfiles.Remove(i).ProcessData)
                    eval(char(configIn.Shortfiles.Remove(i).ProcessData(l)));
                end
            end
        end
     end
 else
     st = [];
 end
 