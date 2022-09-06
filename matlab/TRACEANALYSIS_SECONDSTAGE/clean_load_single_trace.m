
%first stage cleaning

cln = clean_traces(trace_in);				%do the basic cleaning on the trace.   
cln_out = ta_update_statistics(cln);
if ~isempty(cln_out)
   cln = cln_out;
end

trace_str(file_opts.trcInd).stats = cln.stats;

if isfield(cln,'pts_restored') & ~isempty(cln.pts_restored)
   cln.data(cln.pts_restored) = cln.data_old(cln.pts_restored);
end
if isfield(cln,'pts_removed') & ~isempty(cln.pts_removed)
   %Reset all interpolated values:
   cln.data(cln.pts_removed) = NaN;
   if isfield(cln,'interpolated') & ~isempty(cln.interpolated)   
      cln.data(cln.pts_removed) = cln.interpolated(cln.pts_removed);   
   end
end

%trace_str.data = '';

%trace_str.data = cln.data;

if file_opts.trcInd == length(trace_str)
   action = 'terminate';
end

% kai* May 31, 2001
% Moved flag array determination out of export section because it is needed even
% if the current trace is not export
flag_array = find_good_measurements(cln);
[n m] = size(flag_array);
if m>n 
   keyboard;
end
clean_tv = cln.timeVector;
% end kai*

%--------------------------------------------------------------------------------
%Export selected traces to the appropriate directory.
%requires some initial configuration details on the first menu screen.
if export_trc==1    
   % kai* 15 Dec, 2000
   % Output is now done within this function, which is common between
   % first and second stage cleaning.
   if ~exist('export_mat')
      export_mat = [];
   end
   %export_mat = trace_export(file_opts,cln,export_mat);
   clean_tv = cln.timeVector;
   % end kai*
end
