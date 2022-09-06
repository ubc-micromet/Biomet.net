function trace_str_out = read_ini_file(fid,Year)
% This function creates an array of structures based on the parameters in the 
% initialization file.  This structure is used throughout the rest of the
% program.
% Input:		'fid' -this is the file id number associated with the
%						initialization file now open for reading.
%               'year' -this is the year to be added to the year-independent 
%                       initialization file being read
% Ouput:		'trace_str_out' -This is the array of structures representing all
%						the information for each trace in the initialization file.
%
% Basic functionality:
%	Read each line of the initialization file.  Then, for each [TRACE]->[END] block
%	create a stucture and add the fields listed.  Each of these structure is then
%  added to an array of structures and returned in 'trace_str_out'.

% Revisions:
%
% Sep 2, 2004
%   - fixed problem when the program would not process lines with spaces and TAB 
%     characters at the begining of the line (Zoran)

if~exist('Year') | isempty(Year)
   Year = '';							    			%default value of year is empty.
end

%The following fields are required and must be spelled correctly for each trace.
trace_str_out='';
ini_fields = {'title','inputFileName', 'measurementType','units','minMax'};
tm_line=fgetl(fid);
count = 0;
trace_str=[];

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
            sngle_qt = find(curr_line == 39);            
            if length(sngle_qt) == 1 & (isempty(temp_cm) | sngle_qt < temp_cm(1))               
               %A single quote is found, which is not within a comment string.
               %Either an error, OR variable assignment extends over multiple lines.
               %Get the next lines until either the last quote is found or
               %a '=' sign is found.(in this case the single quote is an error):
               eqlind = find(curr_line == '=');
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
                     %error has occured(since quotes can be within comments):
                     if ~isempty(eqlind)
                        if isempty(comnt) | (eqlind(1) < comnt(1))
                           % kai* 06/09/00
                           % The following line read 'on line', but count is the no of the trace!
                           disp(['An error has occured in the ini_file, on trace: ' num2str(count) '!']);
                           % kai* 27/05/2001 
                           % Added output of name of trace if available
                           if isfield(temp_var,'variableName')
                                disp(['Variable ' temp_var.variableName]);
                           end
                           % end kai*
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
                     %if the last quote is found exit while loop(or till end of trace block):                     
                     if fin_str(end) == 39 | findstr(fin_str,'[End]')
                        last_sngl_qt = 1;
                     else
                        %make sure commas separate each line added:
                        if ~isempty(mkstr) & fin_str(end)~=',' 
                           fin_str = [fin_str ','];
                        end
                        %get next line and continue while loop:
                        mkstr = fgetl(fid);                        
                     end  
                  end
                  %exit the while loop and reset the current line to include all strings
                  %extending over multiples lines:
                  eqlind = find(curr_line == '=');
                  %update the curr_line variable assignment with the full string:
                  if ~isempty(eqlind)
                     curr_line = [curr_line(1:eqlind(1)) fin_str];
                  else
                     disp(['Missing variable assignment in trace #' num2str(count) '!']);
                     trace_str_out='';
                     return
                  end                  
               else
                  %there is no '=' sign which is not allowed
                  disp(['Missing equal sign ''='' in trace #' num2str(count) '!']);
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
                  eval(['temp_var.' curr_line ';']);   
               catch   
                  %Any error's are caught in the try-catch block:
                  disp(['Error in the ini_file trace #' num2str(count) '.']);
                  lasterr
                  trace_str_out='';
                  return                 
               end
            end
         end
         %Get next line:
         tm_line = fgetl(fid);                 
      end
      %Test for required fields that the initialization file must have.
      %temp_trace = trace_str(count).ini;
      curr_fields = fieldnames(temp_var);				%get current fields
      chck = ismember(ini_fields,curr_fields);		%check if all fields are present.
      ind = find(chck==0);
      if ~all(chck)											
         %disply error message if not:
         disp(['Error in ini_file  Variable: ' temp_var.variableName ...
               ' (trace # ' num2str(count) ').']);
         disp(['The required field ' char(ini_fields(ind(1))) ' does not exist.']);
         trace_str_out='';
         return
      end  
      %Update the current trace with ini_file information listed outside the 
      %[TRACE]->[END] blocks:
      trace_str(count).Site_name = Site_name;
      trace_str(count).variableName = temp_var.variableName;
      trace_str(count).ini = temp_var;
      trace_str(count).SiteID = SiteID;
      trace_str(count).Year = Year;
      trace_str(count).Diff_GMT_to_local_time = Difference_GMT_to_local_time;
      trace_str(count).Last_Updated = datestr(now);   
   	%---------------Finished reading the trace information between [TRACE]->[END] block 
	 
      elseif isletter_no_white_space(tm_line)
      % changed elseif isletter(tm_line(1)) to isletter_no_white_space to
      % avoid errors when user enters spaces or <TAB> at the beginning of the line (Z. Sep 2, 2004)
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
      %Evaluate the current variable assingment into the current workspace:
      eval([tm_line ';'])		%(siteID,site_name, etc).
   end
   tm_line = fgetl(fid);		%get next line of ini_file
end

trace_str_out = trace_str;		%return the created array of structures

function x = isletter_no_white_space(text_in)
    ind = find(text_in ~= 32 & text_in ~= 9);
    x = isletter(text_in(ind(1)));


