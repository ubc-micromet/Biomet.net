function trace_out = ta_update_statistics(trace_in)

trace_out = [];
if ~isfield(trace_in,'stats') | ~isfield(trace_in.stats,'index')...
      | isempty(trace_in.stats.index)
   return
end
pts_manually_changed = [];
if isfield(trace_in,'pts_restored') & isfield(trace_in,'pts_removed')
   pts_manually_changed = union(trace_in.pts_restored,trace_in.pts_removed);
end   

if isempty(pts_manually_changed)
   return
end
if isfield(trace_in.stats,'clean_flags')
   trace_in.stats.clean_flags = setdiff(trace_in.stats.clean_flags,pts_manually_changed);
end

if isfield(trace_in.stats.index,'PtsDependClean')
   trace_in.stats.index.PtsDependClean = ...
      setdiff(trace_in.stats.index.PtsDependClean,pts_manually_changed);
   trace_in.stats.numpts.dependCleaned = ...
      length(trace_in.stats.index.PtsDependClean);
end
if isfield(trace_in.stats.index,'PtsInterpolated')
   trace_in.stats.index.PtsInterpolated = ...
      setdiff(trace_in.stats.index.PtsInterpolated,pts_manually_changed);   
   trace_in.stats.numpts.Interpolated = ...
      length(trace_in.stats.index.PtsInterpolated);
end
if isfield(trace_in.stats.index,'PtsDespiked')
   trace_in.stats.index.PtsDespiked = ...
      setdiff(trace_in.stats.index.PtsDespiked,pts_manually_changed);
   trace_in.stats.numpts.despiked = ...
      length(trace_in.stats.index.PtsDespiked);
end
if isfield(trace_in.stats.index,'PtsOutsideMin')
   trace_in.stats.index.PtsOutsideMin = ...
      setdiff(trace_in.stats.index.PtsOutsideMin,pts_manually_changed);
   trace_in.stats.numpts.outsideMin = ...
      length(trace_in.stats.index.PtsOutsideMin);
end
if isfield(trace_in.stats.index,'PtsOutsideMax')
   trace_in.stats.index.PtsOutsideMax = ...
      setdiff(trace_in.stats.index.PtsOutsideMax,pts_manually_changed);
   trace_in.stats.numpts.outsideMax = ...
      length(trace_in.stats.index.PtsOutsideMax);
end
if isfield(trace_in.stats.index,'PtsFiltered')
   trace_in.stats.index.PtsFiltered = ...
      setdiff(trace_in.stats.index.PtsFiltered,pts_manually_changed);
   trace_in.stats.numpts.outsideFilter = ...
      length(trace_in.stats.index.PtsFiltered);
end
trace_out =trace_in;