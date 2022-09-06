function trace_str_out = read_ini_file(fid,Year)
% This function creates an array of structures based on the parameters in the 
% initialization file.  This structure is used throughout the rest of the
% program.
% Input:		'fid' -this is the file id number associated with the
%						initialization file now open for reading.
%           'year' -this is the year to be added to the year-independent 
%                       initialization file being read
% Ouput:		'trace_str_out' -This is the array of structures representing all
%						the information for each trace in the initialization file.
%						Each field of the traces structure MUST be added here ... see
%						bellow for the places to enter new trace structure fields.
%                 Note that new fields MUST be added in two distinct places within
%                 the function, again see bellow

%
% Basic functionality:
%	Read each line of the initialization file.  Then, for each [TRACE]->[END] block
%	create a stucture and add the fields listed.  Each of these structure is then
%  added to an array of structures and returned in 'trace_str_out'.

%-------------------------------------------------------------------------------------
% Setup Trace Structure trace_str_default, contains all the fields that
%   are used in the trace structure, note that any changes to trace_str
%   need to be refelected bellow where trace_str is defined for each itteration

disp('Reading ini file ... ');

trace_str = [];

trace_str.stage = 'none';  %stage of cleaning, used later by cleaning functions ('none' = no cleaning, 'first' = first stage cleaning, 'second' = second stage cleaning)
trace_str.Error = 0;       %default error code, 0=no error, 1=read error

trace_str.Site_name = '';
trace_str.variableName = '';
trace_str.ini = [];
trace_st.SiteID = '';
trace_str.Year = '';
trace_str.Diff_GMT_to_local_time = '';
trace_str.Last_Updated = '';
trace_str.data = [];
trace_str.DOY = [];
trace_str.timeVector = [];
trace_str.data_old = [];

%First stage cleaning specific fields
trace_str.stats = [];				%holds the stats about the cleaning
trace_str.runFilter_stats = [];  %holds the stats about the filtering
trace_str.pts_restored = [];		%holds the pts that were restored
trace_str.pts_removed = [];		%holds the pts that were removed

%Second Stage specific fields
trace_str.data = [];        %holds calculated data from Evalutation routine
trace_str.searchPath = '';  %holds the options used to determine the path of the second stage data
trace_str.input_path = '';  %holds the path of the database of the source data
trace_str.output_path = ''; %holds the path where output data is dumped
trace_str.high_level_path = '';
% If the year is missing then set it to empty
if~exist('Year') | isempty(Year)
   Year = '';						
end

% Define which fileds in the ini must exist
required_common_ini_fields = {'variableName', 'title', 'units', 'minMax'}; 
required_first_stage_ini_fields = {'inputFileName', 'measurementType'};
required_second_stage_ini_fields = {'Evaluate1'};

% Set some locally used variables
tm_line=fgetl(fid);
count = 0;
count_lines = 1;

%Read each line of the ini_file given by the file ID number, 'fid', and for each trace
%listed, store into an array of structures:
while isstr(tm_line)
   temp_var = '';
   temp = find(tm_line~=32 & tm_line~=9);  %skip white space outside [TRACE]->[END] blocks
   if isempty(tm_line) | isempty(temp)
      tm_line = 'skip';      
   elseif strcmp(tm_line(temp(1)),'%')		%skip comments outside [TRACE]->[END] blocks				      
      tm_line = 'skip';     
   elseif strncmp(tm_line,'[Trace]',7)    
      %------------------------------------locate each [TRACE]->[END] block in ini_file
      %update which trace this is(used only for error messages):
      count = count+1;					
      %Read the first line inside the [TRACE]->[END] block:
      tm_line = fgetl(fid);
      count_lines = count_lines + 1; 	
      eval_cnt = 0;
      while ~strncmp(tm_line,'[End]',5)   
         %Until the [END] block is found, read each line and add the assigned variables
         %to a temporary structure that will be added to the array of all structures:         
         curr_line = tm_line;      
         %initial indices of spaces and comments:
         temp_sp = [];
         temp_cm = [];	
         if ~isempty(curr_line)            
           	%ignore white space characters by locating first and last non-white space:
            temp_sp = find(curr_line~=32 & curr_line~=9);	           
            if ~isempty(temp_sp)
               curr_line = curr_line(temp_sp(1):temp_sp(end));
            else
               curr_line = '';
            end
            %Find the indices of comment signs:
            if ~isempty(curr_line)
               temp_cm = find(curr_line == '%');		
            end
         end             
         if ~isempty(curr_line)  
            %Find all single quotes on the current line:
            qt = find(curr_line == 39); % all quotes
            % Only quotes that are not follwed by another quote are single
            % quotes:
            if ~isempty(qt)
                dble_qt = find(diff(qt) == 1);
                sngle_qt = setdiff(qt,[qt(dble_qt) qt(dble_qt+1)]);
            else
                sngle_qt = [];
            end
            
            if length(sngle_qt) == 1 & (isempty(temp_cm) | sngle_qt < temp_cm(1))               
               %A single quote is found, which is not within a comment string.
               %Either an error, OR variable assignment extends over multiple lines.
               %Get the next lines until either the last quote is found or
               %a '=' sign is found.(in this case the single quote is an error):
               eqlind = find(curr_line == '=');
%Added February 6, 2006 (dgg)
%A bug in code was preventing normal behavior of this function
%!!!!Temporary fix!!!!:
               eqlindTMP = find(curr_line == '=');               
               %Get the string after the '=' sign.
               mkstr = curr_line(eqlind(1)+1:end);
               if ~isempty(eqlind)
                  fin_str = '';			%initial final string is empty
                  last_sngl_qt = 0;		%flag indicating when last single quote is found
                  while last_sngl_qt == 0
                     %get indices of comment and equal signs:
                     comnt = find(mkstr == '%');
                     eqlind = find(mkstr == '=');               
                     %if an equal sign comes before the closing single quote then an
                     %error has occured(unless the line is an "Evaluate" keyword):
%Added February 6, 2006 (dgg)
%A bug in code was preventing normal behavior of this function
%!!!!Temporary fix!!!!:
%                     if ~isempty(eqlind) & isempty(findstr(curr_line(1:eqlind(1)),'Evaluate'))
                     if ~isempty(eqlind) & isempty(findstr(curr_line(1:eqlindTMP(1)),'Evaluate'))
                        if isempty(comnt) | (eqlind(1) < comnt(1))
                           disp(['Missing variable assignment in trace #' num2str(count) ' on line number: ' num2str(count_lines-1) '!']);
                           trace_str_out='';
                           return
                        end
                        %Continue if no equal sign before a comment
                     end                      
                     %get rid of the comments if they exist:
                     if ~isempty(comnt)
                        mkstr = mkstr(1:comnt(1)-1);
                     end               
                     %get rid of surrounding white space:
                     indchrs = find(mkstr~=32 & mkstr~=9);
                     if length(indchrs)>1
                        mkstr = mkstr(indchrs(1):indchrs(end));                        
                     end                     
                     %Avoid having multiple commas(although this is caught further on):
                     if length(mkstr)>1 & mkstr(1) == ','
                        mkstr = mkstr(2:end);
                     end                     
                     %append to the final string:                   
                     fin_str = [fin_str mkstr];
                     %if the last quote is found exit while loop:                     
               
                     if fin_str(end) == 39 | findstr(fin_str,'[End]')
                        last_sngl_qt = 1;
                     else  
                        %make sure commas separate each line added:
                        if ~isempty(mkstr) & fin_str(end)~=',' 
                           fin_str = [fin_str ','];
                        end
                        %get next line and continue while loop:
                        mkstr = fgetl(fid);        
                        count_lines = count_lines + 1;
                     end  
                  end
                  %exit the while loop and reset the current line to include all strings
                  %extending over multiples lines:
                  eqlind = find(curr_line == '=');
                  %update the curr_line variable assignment with the full string:
                  if ~isempty(eqlind)
                     curr_line = [curr_line(1:eqlind(1)) fin_str];
                  else
                     disp(['Missing variable assignment in trace #' num2str(count) ' on line number: ' num2str(count_lines)  '!']);
                     trace_str_out='';
                     return
                  end                  
               else
                  %there is no '=' sign which is not allowed
                  disp(['Missing equal sign ''='' in trace #' num2str(count) ' on line number: ' num2str(count_lines)  '!']);
                  trace_str_out='';
                  return
               end               
            else
               %in the case of zero or double quotes, evaluate the string as listed
               %in the intialization file without comments(if present):
               if ~isempty(temp_cm)       
                  if temp_cm(1)==1
                     curr_line = '';		
                  elseif isempty(sngle_qt)
                     curr_line = curr_line(1:temp_cm(1)-1);  
                  elseif (sngle_qt(1) > temp_cm(1)) | (sngle_qt(2) < temp_cm(1))
                     curr_line = curr_line(1:temp_cm(1)-1);
                  elseif (sngle_qt(1) < temp_cm(1)) | (sngle_qt(2) > temp_cm(1))
                     curr_line = curr_line(1:sngle_qt(2));
                  end                  
               end
            end 
            
            if ~isempty(curr_line)
               %User 'eval' to add the variable assignment listed in curr_line 
               %to the temporary structure:               
               try     
                  lasterr('')                  
                  if strncmp(curr_line, 'Evaluate',8)
                     eval_cnt = eval_cnt + 1;
                     curr_line = ['Evaluate' num2str(eval_cnt) curr_line(9:end)];                     
                     curr_line = curr_line(find(curr_line~=32 & curr_line~=9));
                  end                  
                  eval(['temp_var.' curr_line ';']);                  
               catch   
                  %Any error's are caught in the try-catch block:
                  disp(['Error in trace #' num2str(count) ' on line number: ' num2str(count_lines) '!']);
                  disp(lasterr); 
                  trace_str_out='';
                  return                 
               end
            end
         end
         %Get next line:
         tm_line = fgetl(fid);                 
         count_lines = count_lines + 1;
      end    
            
      %Test for required fields that the initialization file must have.
      curr_fields = fieldnames(temp_var);															%get current fields
      chck_common = ismember(required_common_ini_fields,curr_fields);						%check to see if the fields that are common to both stages are present
      chck_first_stage = ismember(required_first_stage_ini_fields,curr_fields);		%check to see if the fields that are common to both stages are present
      chck_second_stage = ismember(required_second_stage_ini_fields,curr_fields);		%check to see if the fields that are common to both stages are present
            
      if all(chck_common) 
         if all(chck_first_stage) stage = 'first';
            trace_str(count).stage = 'first';
         end
         
         if all(chck_second_stage) stage = 'second';
            trace_str(count).stage = 'second';
         end         
      else
         disp(['Error in ini file, common required field(s) do not exist']);
         trace_str_out = '';
         return
      end
      
      if strcmp(stage,'none')
         disp(['Error: Unrecognized ini file format']);
         trace_str_out = '';
         return
      end
      
      %Update the current trace with ini_file information listed outside the 
      %[TRACE]->[END] blocks:
      
      %**** Trace structure defined for each itteration of the array ******
		trace_str(count).Error = 0;      	
		trace_str(count).Site_name = '';
		trace_str(count).variableName = '';
      trace_str(count).ini = [];
      trace_str(count).SiteID = '';
		trace_str(count).Year = '';
		trace_str(count).Diff_GMT_to_local_time = '';
		trace_str(count).Last_Updated = '';
		trace_str(count).data = [];
		trace_str(count).DOY = [];
		trace_str(count).timeVector = [];
		trace_str(count).data_old = [];
      
      trace_str(count).stats = [];
      trace_str(count).runFilter_stats = [];  
      trace_str(count).pts_restored = [];		
      trace_str(count).pts_removed = [];	
      
      %Set the trace structure to it's actual data
      trace_str(count).Site_name = Site_name;
      trace_str(count).variableName = temp_var.variableName;
      trace_str(count).ini = temp_var;
      trace_str(count).SiteID = SiteID;
      trace_str(count).Year = Year;
                 
      switch trace_str(count).stage
      case 'first'
         trace_str(count).Diff_GMT_to_local_time = Difference_GMT_to_local_time;
         trace_str(count).Last_Updated = datestr(now);   

		case 'second'
         % kai* 14 Dec, 2000 
	      % inserted the measurement_type field to facilitate easier output
   	   % end kai*

         trace_str(count).ini.measurementType = 'high_level';
         trace_str(count).searchPath = searchPath;  
      
	      if ~isempty(input_path) & input_path(end) ~= '\'
	         input_path = [input_path filesep];
	      end
	      if ~isempty(output_path) & output_path(end) ~= '\'
	         output_path = [output_path filesep];
	      end
     
	     %Elyn 08.11.01 - added year-independent path name option
   	  ind_year = findstr(lower(input_path),'yyyy');
	     if isempty(ind_year) & length(ind_year) > 1
   	      error 'Year-independent paths require a wildcard: yyyy!'
	     end
	     if ~isempty(ind_year) & length(ind_year) == 1            
	         input_path(ind_year:ind_year+3) = num2str(Year);
	     end
     
	      trace_str(count).input_path = input_path;
	      trace_str(count).output_path = output_path;
	      trace_str(count).high_level_path = high_level_path;
         trace_str(count).Last_Updated = datestr(now);   
      end
   	%---------------Finished reading the trace information between [TRACE]->[END] block 
	 
   elseif isletter(tm_line(1))				
      %read other variables in the ini_file not between [TRACE]->[END] blocks:
      %These variable need to begin with a character:
      sngle_qt = find(tm_line == 39);				%indices of single quotes
      comment_ln = find(tm_line == '%');			%indices of comments
      if ~isempty(comment_ln)
         %if comments exist, check where the single quotes are:
         if isempty(sngle_qt) | (sngle_qt(1) > comment_ln(1)) |...
               (sngle_qt(2) < comment_ln(1))
            tm_line = tm_line(1:comment_ln(1)-1);
         end
      end   
      if findstr(tm_line,'searchPath')
         rem_spc = find(tm_line~=32 & tm_line~=9);
         tm_line = tm_line(rem_spc);     
      end      
      %Evaluate the current variable assingment into the current workspace:      
      eval([tm_line ';'])		%(siteID,site_name, etc).    
   end
   tm_line = fgetl(fid);		%get next line of ini_file
   count_lines = count_lines + 1;
end

if 0 == 1
%if strcmp(trace_str(count).stage,'second')
	% kai* 25.11.2000
	% Erase the ... from the Evaluate string.
	for i  = 1:length(trace_str)
	   ind_points = findstr(trace_str(i).ini.Evaluate1,'...');
	   if ~isempty(ind_points)
	      ind_delete = [];
	      for j=1:length(ind_points)
	         ind_delete(end+1:end+3) = ind_points(j):ind_points(j)+2;
	      end
      
	      ind_keep = setdiff(1:length(trace_str(i).ini.Evaluate1),ind_delete);
	      trace_str(i).ini.Evaluate1 = trace_str(i).ini.Evaluate1(ind_keep);
	   end
	end

	% end kai*
end               

trace_str_out = trace_str;		%return the created array of structures