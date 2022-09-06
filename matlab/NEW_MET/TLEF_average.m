function climateData = TLEF_average(traceInfo)
%   climateData = TLEF_average(traceInfo)
%       
% This function calculates daily, monthly, seasonal and annual averages and totals.
%
% The input structure has the following elements:
%
% traceInfo
%   .Year       - year
%   .FieldName  - filed name of the results in the output structure
%   .Totalize   - a flag.  0 - don't totalize, 1 - totalize
%   .tv         - time vector. Uniformly spaced but spacing can be
%                 30-minutes, 1 hour or 1 day.
%   .X          - the actual values that are being averaged
%
% Output structure:
%
% climateData
%   .(FieldName).

% Revisions:
%
% Apr 29, 2013 (Zoran)
%   - changed local function totalize. Commented out the second condition
%   on this line:
%           if ~all(isnan(x)) % & n > 0 
%   because the n is an array and any zeros in this array would make this
%   condition to become false.  Had a bad effect on calculating current
%   years precipitation daily totals. 
% Sep 9, 2010 (Zoran)
%   - Fixed bug Summer should start in June not in July
%

    currentYear = traceInfo.Year;
    d = datevec(now);
    % if processing current year remove the incomplete last day created by
    % the GMT shift of the data.  
    DaysInYear = datenum(currentYear+1,1,1)-datenum(currentYear,1,1);
    if currentYear == d(1)
        DaysInYear = DaysInYear - 1;
    end
    % find out how many points are sampled per day
    Day_points = floor(length(traceInfo.tv)/DaysInYear);
    
    
    % Store the input data
    climateData.(traceInfo.FieldName).Data = traceInfo.X;
    climateData.(traceInfo.FieldName).tv   = traceInfo.tv;
    climateData.(traceInfo.FieldName).Units = traceInfo.Units;
    
    % Daily averages
    [climateData.(traceInfo.FieldName).Avg.Daily N] = ...
                 fastavg_local(traceInfo.X,Day_points);
    % Daily time vector
    climateData.(traceInfo.FieldName).Avg.tv = datenum(currentYear,1,(1:DaysInYear)');
    if traceInfo.Totalize
        climateData.(traceInfo.FieldName).Total.Daily = ...
               totalize(climateData.(traceInfo.FieldName).Avg.Daily,N); 
    end
    
    
    % Annual averages
    [climateData.(traceInfo.FieldName).Avg.Annual N] = ...
                 fastavg_local(traceInfo.X,length(traceInfo.X));
    if traceInfo.Totalize
        climateData.(traceInfo.FieldName).Total.Annual = ...
               totalize(climateData.(traceInfo.FieldName).Avg.Annual,N); 
    end
    
    % Seasonal averages
    % Winter
    tv_s1 =  datenum(currentYear,1,1);
    tv_e1 =  datenum(currentYear,3,21);
    tv_s2 =  datenum(currentYear,12,21);
    tv_e2 =  datenum(currentYear+1,1,1);
    ind_Winter = find((traceInfo.tv >tv_s1 & traceInfo.tv <= tv_e1)| ...
                      (traceInfo.tv >tv_s2 & traceInfo.tv <= tv_e2));
    [climateData.(traceInfo.FieldName).Avg.Winter N_Winter] = ...
                      fastavg_local(traceInfo.X(ind_Winter),length(ind_Winter)); %#ok<*FNDSB>
    % Spring
    tv_s1 =  datenum(currentYear,3,21);
    tv_e1 =  datenum(currentYear,6,21);
    ind_Spring = find((traceInfo.tv >tv_s1 & traceInfo.tv <= tv_e1));
    [climateData.(traceInfo.FieldName).Avg.Spring N_Spring]= ...
                      fastavg_local(traceInfo.X(ind_Spring),length(ind_Spring));
    % Summer
    tv_s1 =  datenum(currentYear,6,21);
    tv_e1 =  datenum(currentYear,9,23);
    ind_Summer = find((traceInfo.tv >tv_s1 & traceInfo.tv <= tv_e1));
    [climateData.(traceInfo.FieldName).Avg.Summer N_Summer]= ...
                     fastavg_local(traceInfo.X(ind_Summer),length(ind_Summer));
    % Fall
    tv_s1 =  datenum(currentYear,9,23);
    tv_e1 =  datenum(currentYear,12,21);
    ind_Fall = find((traceInfo.tv >tv_s1 & traceInfo.tv <= tv_e1));
    [climateData.(traceInfo.FieldName).Avg.Fall N_Fall]= ...
                     fastavg_local(traceInfo.X(ind_Fall),length(ind_Fall));
    
    if traceInfo.Totalize
        climateData.(traceInfo.FieldName).Total.Winter = ...
               totalize(climateData.(traceInfo.FieldName).Avg.Winter,N_Winter); 
        climateData.(traceInfo.FieldName).Total.Spring = ...
               totalize(climateData.(traceInfo.FieldName).Avg.Spring,N_Spring); 
        climateData.(traceInfo.FieldName).Total.Summer = ...
               totalize(climateData.(traceInfo.FieldName).Avg.Summer,N_Summer); 
        climateData.(traceInfo.FieldName).Total.Fall = ...
               totalize(climateData.(traceInfo.FieldName).Avg.Fall,N_Fall); 
    end
    
    % Monthly
    Months = {'Jan','Feb','Mar','Apr','May','Jun',...
              'Jul','Aug','Sep','Oct','Nov','Dec'};
    for i=1:12
        tv_s1 =  datenum(currentYear,i,1);
        tv_e1 =  datenum(currentYear,i+1,1);
        ind_season = find((traceInfo.tv >tv_s1 & traceInfo.tv<= tv_e1));
        MonthFieldName = char(Months(i));
        [climateData.(traceInfo.FieldName).Avg.(MonthFieldName), N] = ...
                    fastavg_local(traceInfo.X(ind_season),length(ind_season));
        if traceInfo.Totalize
            climateData.(traceInfo.FieldName).Total.(MonthFieldName) = ...
                totalize(climateData.(traceInfo.FieldName).Avg.(MonthFieldName), N);
        end
    end    
end

function [y,y_nanFlag] = fastavg_local(x,periodToAvg)
    if isnan(periodToAvg) | periodToAvg == 0 | isempty(x)
        y = NaN;
        y_nanFlag = NaN;
    else
        [y,y_nanFlag] = fastavg(x,periodToAvg);
        % for each period where there is less than 90% of not-nan values
        % set the average for that period to NaN
        ind = find((y_nanFlag / periodToAvg) < 0.9);
        y(ind) = NaN;
    end
end
function TotalX = totalize(x,n)
    if ~all(isnan(x)) % & n > 0 %#ok<*AND2>
        TotalX = x .* n;
    else
        TotalX = NaN;
    end
end