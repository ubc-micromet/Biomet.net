function finish()
return
UserData = get(0,'UserData');
eval('base','diary off');
fid = fopen(UserData.DiaryFileName,'a');
fprintf(fid,'**************************************************\n');
fprintf(fid,'Matlab instance: %s\n',UserData.instance);
fprintf(fid,'Finished at: %s\n', datestr(now));
fprintf(fid,'**************************************************\n');
