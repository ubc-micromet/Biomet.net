function data_out = compare_trace_str(trace_str,old_structure,lc_path)
%This function compares the two input array structures, 'trace_str' and 'old_structure'.
%Inside each of these structures should be variable names, site identifications, and year
%fields.  These structures should also contain a 'ini' field containing all the 
%information listed in the initialization file.
%These structures can contain different traces, and have fields that don't match.
%The user can save a text file containing a list of all differences to a specified
%location on the local computer.
%
%NOTE: if there are no differences found, this function will return without any warnings
%and will not prompt the user for any input.
%
%	Input:	'trace_str'			-the array structure of all traces listed in the ini_file.
%				'old_structure'	-the array structure of all traces listed in the mat_file.
%				'lc_path'			-the local path of the ini_file and/or mat_file.
%
%	Output:	'data_out'			-A flag indicating program action for the calling function.
%										This flag is set to either continue or cancel depending
%										on user input OR if mandatory fields in the two
%										structures don't match(siteID,year,siteName).
%
%------------------------------------------------------------------------------------
% Revisions: E.Humphreys Nov 8, 2001 - introduced char command to allow cellstr within ini file

%Get names of all traces in ini_file, and mat_file.
trcNames = {trace_str.variableName};
oldNames = {old_structure.variableName};

%Check if all variables in mat_file are present in ini_file.
not_present_mat = trcNames(find(ismember(trcNames,oldNames)==0));
not_present_ini = oldNames(find(ismember(oldNames,trcNames)==0));

[present, a, b] =intersect(oldNames,trcNames);	%get indices of correponding traces.
a=a';
b=b';
data_out = 'cancel';			%default program action is cancel.
%Check for necessary fields that must be the same:
% kai* 10 Nov, 2000
% Inserted this since the if statements below do not work if all names are different
if isempty(b)
   warndlg('All names in the ini_file are different from those in the mat_file!')
else
   % this is still original
   if ~strcmp(trace_str(b(1)).SiteID,old_structure(a(1)).SiteID)  
      warndlg('The site ID in the ini_file is different than in the mat_file!')
      return
   end
   if ~strcmp(trace_str(b(1)).Site_name,old_structure(a(1)).Site_name)
      warndlg('The site name in the ini_file is different than in the mat_file!')
      return
   end
   if trace_str(b(1)).Year ~= old_structure(a(1)).Year   
      warndlg('The Year in the ini_file is different than in the mat_file!')
      return
   end
end
% end kai*
%---------------------------------------------------------------------------------
%Check each trace in the ini_file and mat_file for differences:
all_diff = [];
h=waitbar(0,'Comparing input files...');
ct = length(b);
for i=1:length(b)
   trc = trace_str(b(i));				%get first trace
   old = old_structure(a(i));			%get corresponding trace in the old structure(mat_file)
   ini_trc = trc.ini;					%get the ini structures
   ini_old = old.ini;
   specs_trc = fieldnames(ini_trc);	%get the field names for each ini structure
   specs_old = fieldnames(ini_old);      
   s_old='';
   %For each trace present in both ini_file and mat_file, check all ini field differences:
   for j=1:length(specs_trc)			
      %Get the value of each field listed in the ini structure:
      val_trc = getfield(ini_trc,char(specs_trc(j)));
      if ~isstr(val_trc)
          %if not string, convert to string: 
          if iscell(val_trc)
              val_trc = mat2str(char(val_trc));
          else
              val_trc = mat2str(val_trc);
          end      
      end
      if ismember(specs_trc(j),specs_old)		
         %If the ini parameter in the ini_file is present in the mat_file, compare value:
         val_old = getfield(ini_old,char(specs_trc(j)));
         if ~isstr(val_old)
             %convert to string if necessary:
             if iscell(val_old)
                 val_old = mat2str(char(val_old));
             else
                 val_old = mat2str(val_old);
             end            
         end
         %check if values are identical, if not then track differences:
         if ~strcmp(val_trc,val_old)
            %format string indicating differences and append to a list of all differences:
            s = sprintf('   %-35.50s%-35.50s%-s',char(specs_trc(j)),val_trc,val_old);
            s_old = strvcat(s_old,deblank(s));        
         end      
      else
         %format string indicating the ini parameter is missing:
         s = sprintf('   %-35.50s%-35.50s%-s',char(specs_trc(j)),val_trc,'missing'); 
         s_old = strvcat(s_old,deblank(s));
      end
   end
   %check if parameters present in the mat_file are not present in the ini_File:
   for j=1:length(specs_old)      
      if ~ismember(specs_old(j),specs_trc)
         %if not member then, get value:
         val_old = getfield(ini_old,char(specs_old(j)));
         if ~isstr(val_old)
             %convert to string if necessary:
             if iscell(val_old)
                 val_old = mat2str(char(val_old));
             else
                 val_old = mat2str(val_old);
             end         
         end
         %Parameter is missing so append to list of all differences:
         s = sprintf('   %-35.50s%-35.50s%-s',char(specs_old(j)),'missing',val_old); 
         s_old = strvcat(s_old,deblank(s));
      end
   end
   %Set the structure containing strings of all differences:
   if ~isempty(s_old)
      all_diff = setfield(all_diff,char(trcNames(b(i))),s_old);
   end
   if ishandle(h)
      waitbar(i/ct);
   end   
end
if ishandle(h)
   delete(h);
end

%done checking for differences in the two structures
%---------------------------------------------------------------------------------

%Next step create the entire table that will be written to a text file:
table='';
%Check what trace are present in the ini_file but not in the mat_file and append
%them to a text table:
if ~isempty(not_present_mat)
   table = 'Trace variables present in the ini_file but not present in the mat_file:';
   table = strvcat(table,' ');
   table = strvcat(table,char(not_present_mat));
   table = strvcat(table,' ');
end
%Check what trace are present in the mat_file but not in the ini_file and append
%them to a text table:
if ~isempty(not_present_ini)
   table = strvcat(table,'Trace variables present in the mat_file but not present in the ini_file:');
   table = strvcat(table,' ');
   table = strvcat(table,char(not_present_ini));
   table = strvcat(table,' ');
end
%If any differences are present in the initialization information in the mat_file 
%and ini_file append the result to the text table:
if ~isempty(all_diff)
   table = strvcat(table,'Differences found:');
   table = strvcat(table,' ');
   table = strvcat(table,'TRACE NAMES:		 		INI_FILE			MAT_FILE');
   traceNames = fieldnames(all_diff);
   for i=1:length(traceNames)
      table = strvcat(table, char(traceNames(i)));
      temp = getfield(all_diff,char(traceNames(i)));
      table = strvcat(table,temp);
   end
end

%If differences found, warn the user, and save a difference text file to 
%a user specified location:
data_out = 'continue';
if ~isempty(table)
   %Prompt user for response either to cancel program or continue:
   dlg_ans=questdlg('WARNING: Differences between input files!', ...
      '','Cancel','Continue','Continue');
   if strcmp(dlg_ans,'Cancel')
      data_out = 'cancel';
   end  
   %Create a text file with same name as the ini_file/mat_file, but append '_diff.txt'
   %to the end.
   ind  = find(lc_path == '.');
   lc_path = [lc_path(1:ind(end)-1) '_diff.txt'];   
   %Prompt user to save list of differences:
   [fn pth] = uiputfile([lc_path],'Save List Of Differences:');
   if fn~=0      
      fid=fopen([pth fn],'wt');		%open the text file for reading
      for i=1:length(table(:,1))
         fprintf(fid,'%s\n',table(i,:));		%write to the text file
      end
      fclose(fid);
   end   
end