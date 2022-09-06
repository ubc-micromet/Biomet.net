function [outputMatrix,outputDateTime] = plt_msig(pth, indTimeGMT, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,coeff,offset )
%[outputMatrix,outputDateTime] = plt_msig(pth, indTimeGMT, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,coeff,offset )
%
% [outputTraces] = plt_msig1( pth, startDate,endDate, trace_name, trace_legend, trace_units, y_axis, fig_num,coeff,offset )
%
% This function reads multiple traces from the data base and plots them.
%
%   Input parameters:
%        pth         - data file names or data matrix
%        indTimeGMT  - index of data points in GMT time (data base tv before GMT offset shift) 
%        trace_name    - string with the trace names,
%        trace_legend - legend
%        trace_units - string with the trace units
%        y_axis      - [ymin ymax] axis limits
%        t           - t is datenum(year,1,t) in local time (same length as indTimeGMT)                     
%        fig_num     - figure number
%        coeff       - multipliers for each trace
%        offset      - offsets for each trace
%
%  Output parameters:
%       outputMatrix    - matrix with as many columns as pth variables
%                      and as many raws as indTimeGMT
%       outputDateTime  - local time, same size as outputMatrix
%
%
% (c) Zoran Nesic               File created:       Jan  2, 2022
%                               Last modification:  Jan 29, 2022
%

% Revisions:
% 
%  Jan 29, 2022 (Zoran)
%   - the program does not remove anymore leading and trailing zeros. 
%     It replaces them with NaNs.
%  Jan 19, 2022 (Zoran)
%   - added option to skip plotting if pth = [].
%  Jan 7, 2022 (Zoran)
%   - debugging
%  Jan 2, 2022 (Zoran)
%   - file created based on plt_msig function
%

% return if the pth is empty (simplifies automated plotting for multiple sites
% the calling program can assing [] to pth if the variable does not exist at that site
if isempty(pth)
    outputMatrix = [];
    return
end


lineWidth = 2;

figure(fig_num)
set(fig_num,'menubar','none',...
            'numbertitle','off',...
            'Name',trace_name);
pos = get(0,'screensize');
set(fig_num,'position',[8 pos(4)/2-20 pos(3)-20 pos(4)/2-35]);      % universal
clf
LineTypes = char('-','-','-','-','-','-','-','--','--','--','--','--','--',':',':',':',':',':',':',':');

% do some createive fixes to extract startDateIn and endDateIn as datetime
% vars.
tvIn = datetime(fr_round_time(datenum(year,1,t)),'convertfrom','datenum');
startDateIn = tvIn(1);
endDateIn = tvIn(end);

% round up the input dates (startDate to the begining of the day and
% endDate to the end of the day:
startDate = dateshift(startDateIn,'start','day');
[startYear,~,~,~,~,~] = datevec(startDate);

% make sure endDateIn does not fall on Dec 31, yyyy
[endYear,~,~,~,~,~] = datevec(endDateIn);
if endDateIn == datetime(endYear+1,1,1)
    % keep endDate as is, roll the year back
    endDate = endDateIn;
    endYear = endYear-1;
else
    % keep the endYear and shift the endDate to the end of the day
    endDate = dateshift(endDateIn,'end','day');
   %[endYear,~,~,~,~,~] = datevec(endDate);
end


% in case that this is a multiyear trace
rangeYears = startYear:endYear;

% fullDTV = datetime(...
%                   fr_round_time(datenum(startYear,1,1,0,30,0):1/48:datenum(endYear,12,31,24,0,0)),...
%                   'convertfrom','datenum')';
% ind = find(startDate<= fullDTV & endDate >= fullDTV);
% t = fullDTV(ind);
try
    if exist('pth','var') & ischar(pth)
        [N,m] = size(pth);
        if N > m
            error 'Wrong path matrix format: num.of rows > num.of columns!';
        end
        LOAD_DATA = 1;
    else
        [m,N] = size(pth);              %#ok<*ASGLU> % if pth is not a string than assume that it containes data
        LOAD_DATA = 0;                  % flag that enables data loading is set to FALSE
    end
    arg_default('offset',zeros(1,N));
    arg_default('coeff',ones(1,N));

    outputMatrix = [];
    kk = 0;
    legend_string = [];
    for traceNum=1:N
        if LOAD_DATA == 1 
            filePathTemplate = deblank(pth(traceNum,:));
            filePath = filePathTemplate;
            if length(rangeYears) > 1  
                % check if filePath contains 'yyyy' wildcard or if contains
                % a fixed year (endYear)
                strInd = strfind(filePath,'yyyy');
                if isempty(strInd)                                 %#ok<*STREMP>
                    % check if there is a fixed year in the path that
                    % matches input variable "year" 
                    strInd = strfind(filePath,sprintf('%d',endYear));
                    if ~isempty(strInd)
                        filePath(strInd:strInd+3) = 'yyyy';
                    else
                        % if not, maybe the calling program inserted a
                        % endYear-1 (this can happen due to rounding up)
                        strInd = strfind(filePath,sprintf('%d',endYear-1));
                        if ~isempty(strInd)
                            filePath(strInd:strInd+3) = 'yyyy';
                        end
                    end
                end
            end
            plotX = tvIn;
            outputDateTime = tvIn;            
            try
                plotY = read_bor(filePath,1,[],rangeYears);             % get the data from the data base
                plotY = plotY(indTimeGMT);
                % replace the leading and trailing
                % zeros with NaNs
                plotY = replace_zeros(plotY,NaN);                
                outputMatrix   = [outputMatrix plotY];      % extract the requested period
                % the following lines used to remove leading and trailing zeros. 
                % that seems to be a wrong idea for most plots. 
                % "replace_zeros" statement deals with zeros. (Zoran 20220129)
%                 [plotY,indx] = del_num(plotY,0,0);          % remove leading zeros from tmp
%                 plotX = tvIn(indx);                                     % match with tx
%                 [plotY,indx] = del_num(plotY,0,1);                      % find trailing zeros in tmp
%                 plotX = plotX(indx);                                    % match with tx

            catch
                % if the current trace does not exist 
                % plot NaNs (Zoran 20100105)
                plotY = NaN * ones(length(tvIn),1);
                outputMatrix = [outputMatrix plotY]; %#ok<*AGROW>
            end       
        else
            plotX = tvIn;
            plotY = pth(:,traceNum);
            if length(plotY) > length(indTimeGMT)
                plotY = plotY(indTimeGMT);
            end
            outputMatrix = pth;
        end

        kk = kk + 1;
        if kk > size(LineTypes,1) 
            kk = 1;
        end
        
        plotY(find(abs(plotY)>1e10)) = NaN;  %#ok<*FNDSB>
        plot(plotX,plotY.*coeff(traceNum) - offset(traceNum),LineTypes(kk,:),'linewidth',lineWidth)
        hold on
        if ~isempty(trace_legend)
            if traceNum == 1
                legend_string = sprintf('%s%s%s,',char(39),trace_legend(traceNum,:),char(39));
            else
                legend_string = sprintf('%s%s%s%s,',legend_string,char(39),trace_legend(traceNum,:),char(39));
            end
        end
    end
    hold off
    
    if ~isempty(y_axis)
        ylim(y_axis);
    else
        ylim('auto');
        y_axis=ylim;
    end
    xlim([startDate endDate]);
    ax = xlim;
    
    % select the color of the auxilary lines to be plotted below
    if all(get(gcf,'color') == [0 0 0])
        aux_lin_col = [1 1 1];
    else
        aux_lin_col = [0.8 0.8 0.8];
    end
    % plot zero line if zero is visible on the graph (z Dec 22, 2008)
    if y_axis(1)<= 0 & y_axis(2)>= 0
        zeroLine = 1;   % zero line plotted
        line(ax(1:2),zeros(1,2),'color',aux_lin_col,'linewidth',2,'linestyle','-')
    else
        zeroLine = 0;   % no zero line
    end
    % plot a vertical line where the last day starts to aid figuring out if
    % there is some missing data:
    line([endDate-1 endDate-1],...
          y_axis,'color',aux_lin_col,'linewidth',2,'linestyle','-')
        
    grid
    zoom on
    title(trace_name)
    %xlabel(sprintf('DOY (Year = %d)',year))
    ylabel(trace_units)
    if ~isempty(legend_string) & N > 1 %#ok<*AND2>
        c = sprintf('h = legend(%s,''%s'',''%s'');',legend_string(1:end-1),'location','northeast');
        eval(c);
    %    axes(h); %commented out by Rick, to save graph axis info May 25, 1998
    end
    set(gca,'FontSize',12)
    set(gca,'linewidth',1.5)
    set(gca,'gridlinestyle',':')
    % move zero line and vertical line indicating the current DOY into
    % background. Do that by moving their handles forward.
    hTmp = get(gca,'chi');
    hTmpLen = length(hTmp);
    if zeroLine 
        set(gca,'children',hTmp([3:hTmpLen 1 2 ]))
    else
        set(gca,'children',hTmp([2:hTmpLen 1 ]))
    end
catch ME
    clf
    text(0.03,0.5,'Error while plotting (function: plt\_msig.m)');
    if exist('i','var') & exist('pth','var')
        text(0.03,0.4,deblank(pth(traceNum,:)));
    end
    text(0.03,0.3,'Error message:');
    xxx = ME;
    text(0.03,0.2,['"' xxx.message '"' ]);
end

function y = replace_zeros(x_in,replacementNum)
% replace leading and trailing zeros with (usually) NaNs. 
% Useful when the data range is wider than the number of 
% non-zero numbers in the data base. Mainly useful because the
% leading and trailing zeros mess up the ylim auto-scaling
y = x_in;
ind = find(y~=0);
y([1:ind(1)-1 ind(end)+1:end]) = replacementNum;


