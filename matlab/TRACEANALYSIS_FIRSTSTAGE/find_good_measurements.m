function good_measurements = find_good_measurements(trace_str)
%	good_measurements = find_good_measurements(trace_str)
%
%	Returns a vector that is one for those data points in trace_str that have not been removed
%	and/or interpolated and zero otherwise

good_measurements = ones(length(trace_str.data),1);

% Unfortunately some of these statistics are rows and others are columns, so first they
% all have to become colums
ind_str = {'trace_str.pts_removed',...
      'trace_str.stats.index.PtsDependClean',...
      'trace_str.stats.index.PtsOutsideMin',...
      'trace_str.stats.index.PtsOutsideMax',...
      'trace_str.stats.index.PtsDespiked',...
      'trace_str.stats.index.PtsClampedMin',...
      'trace_str.stats.index.PtsClampedMax',...
      'trace_str.stats.index.PtsPastCurrentDate',...
      'trace_str.stats.index.PtsFiltered'};

ind_bad_measurements =[];
for str = ind_str
    if isfield(trace_str,str)==1
        eval(['[n m] = size(' char(str) ');']);
        if m>n 
            eval([char(str) ' = ' char(str) ''';']);
        end
        eval(['ind_bad_measurements = [ind_bad_measurements; ' str '];']);
    end
end

% Remove double entries and sort indecies
ind_bad_measurements = unique(ind_bad_measurements);

good_measurements(ind_bad_measurements) = 0;