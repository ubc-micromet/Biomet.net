function [chck,trace_str] = get_traces_db(SiteID,Year,MeasID,options,user_path)

% last modified: July 2, 2010

% revisions:
%   
%  Nov 15, 2019 (Zoran)
%   - removed "ver" from: [pth_loc,fl_name,ext,ver] = fileparts(file_name);
%     Newer Matlab versions don't have that output
%   - removed a few editor warnings 
%   - the two warnings that I kept are probably indicating a bug. The part
%     coded by "% kai* 24/11/00" cannot be right.  Variables "i" and
%     "file_name" are random at that point.  I didn't want to change this
%      due to a lack of time to fully test.
%  July 2, 2010
%   -modified clean tv filename check to handle other tv's of varying
%    frequency
% Jan 24, 2007: Nick modified 'read all' option to handle high freq time
%               vectors

% This function creates column vectors for selected traces from either the database 
% (at high level or low level clean directories), OR a local directory.
% The column variables are assigned in the calling workspace.
%
%   Inputs: SiteID      :site identification(bs=old black spruce). Used for reading
%                        from the biomet database.
%           Year        :Year to read from in the biomet database
%           MeasID      :flag indicating type of measurement for reading low-level
%                        cleaned traces('fl','cl','ch') or set to 'high_level' for
%                        reading from the high level cleaned directory.
%           options     :An optional flag-
%                              'view_db' 	-view menu to choose traces from the database
%                              'read_all'  -read all trace at Year/siteID/MeasID/Clean
%														or Year/siteID/Clean for high level traces.
%                        OR "options" can be a cell array listing traces in the database.
%           user_path   :The user_path specifies a local directory where traces in 
%                        in binary form are located.
%
%	Examples:
%      get_traces_db('bs',2000,'cl',{'air_temperature_hmp_25m','air_temperature_hmp_6m'})
%      get_traces_db('pa',2000,'high_level','read_all')
%      get_traces_db('pa',2000,'fl','read_all')
%      get_traces_db('','','','read_all','c:\temptraces\')
%				
chck = 1;
if ~exist('options') | isempty(options) %#ok<*EXIST>
   options = 'view_db';
end
if ~exist('Year') | isempty(Year)
   Year = 2000;   
end
if ~exist('SiteID') | isempty(SiteID)			%Default site is cambpell river
   SiteID = 'cr';   
end
if ~exist('MeasID') | isempty(MeasID)
   MeasID = 'high_level';		%flag for the high level clean directory for year and site.
end
if ~exist('user_path')
   user_path = '';
end

%read all traces from the location specified by Year,SiteID,MeasurementType,user path
wildcard = 'yyyy';
if ~isempty(user_path)
   if user_path(end) ~= filesep
      user_path = [user_path filesep];
   end   
   db_pth = user_path;%user directory
else
   % kai* 24/11/00
   % added wildcard and hence possibility to read multiple years with this program
   
   if strcmp(lower(MeasID),'high_level') | strncmp(lower(MeasID),'clean\',6) %#ok<*STNCI,*OR2>
      db_pth = biomet_path(wildcard, SiteID,MeasID);
   else
      db_pth = biomet_path(wildcard, SiteID, MeasID);
      db_pth = [db_pth 'Clean' filesep];
   end
   % end kai*
end


%Get all Trace variables in current directory

if iscellstr(options)
   for i=1:length(options)
      file_name = char(options(i));
      try
         % kai* 24/11/00
         % Before this read
         % data_out = read_bor([db_pth file_name]);
         % added reading of time vector clean_tv and multiple years     
         %if strcmp(file_name,'clean_tv') == 0
         if isempty(strfind(file_name,'clean')) & isempty(strfind(file_name,'tv')) %#ok<*AND2> % Nick July 16/2010
            data_out = read_bor([db_pth file_name],[],[],Year,[],1);     
         else
            data_out = read_bor([db_pth file_name],8,[],Year,[],1);          
         end
         % end kai*
         assignin('caller',file_name,data_out);  		%assign variable into calling workspace
         trace_str(i).variableName = file_name; %#ok<*AGROW>
         trace_str(i).data = data_out;
      catch %#ok<*CTCH>
         chck = 0;
      end
   end
elseif strcmp(lower(options), 'read_all')
   ind_y = strfind(db_pth,'yyyy');
   db_dir = db_pth;
   if ~isempty(ind_y)
      db_dir(ind_y:ind_y+3) = num2str(Year(1));
   end
   dirNames = dir(db_dir);
   % kai* 30 Nov, 2000
   % Before this read 
	% dirNames = {dirNames.name};
   % if length(dirNames) > 2 
   dir_flag = [dirNames.isdir];
   dirNames = {dirNames.name};
   % kai* 30 Nov, 2000
   % Before this read 
   % if length(dirNames) > 2 
   ind_files = find(dir_flag == 0);
   ind_datafiles = [];
   dirNames = dirNames(ind_files); %#ok<*FNDSB>
   for i=1:length(dirNames)
      file_name = char(dirNames(i));
      [pth_loc,fl_name,ext] = fileparts(file_name);
      if isempty(ext)
         try
            % kai* 24/11/00
            % Before this read
            % data_out = read_bor([db_pth file_name]);
            % added reading of time vector clean_tv and multiple years 
            % nick 1/24/07: added check for HF time vector
            % nick 6/1/2010: modified check to handle other tv's of varying
            % frequency
            %if strcmp(file_name,'clean_tv') == 0 & strcmp(file_name,'clean_3min_tv') == 0
            if isempty(strfind(file_name,'clean')) & isempty(strfind(file_name,'tv'))
               data_out = read_bor([db_pth file_name],[],[],Year,[],1);     
            else
               data_out = read_bor([db_pth file_name],8,[],Year,[],1);          
            end
            % end kai*
            assignin('caller',fl_name,data_out);  		%assign variable into calling workspace
            trace_str(i).variableName = file_name;
            trace_str(i).data = data_out;
	         ind_datafiles = [ind_datafiles i];
         catch
            chck = 0;
         end
      end
   end
   if exist('trace_str') == 1
       trace_str = trace_str(ind_datafiles);    
   else
       disp(['No traces loaded from ' user_path]);
       trace_str = [];
   end

elseif strcmp(lower(options),'view_db') %#ok<*STCI>
   %A menu to read from the database.  The interface is done but functionality doesn't exist yet.
   %View_DatabaseClean 
else
   %Load single trace from database   
   [pth_loc,fl_name,ext] = fileparts(options);    %#ok<*ASGLU>
   if isempty(ext)
      try
         % kai* 24/11/00
         % Before this read
         % data_out = read_bor([db_pth file_name]);
         % added reading of time vector clean_tv and multiple years     
         %if strcmp(file_name,'clean_tv') == 0
         if isempty(strfind(file_name,'clean')) & isempty(strfind(file_name,'tv')) % Nick July 16/2010
            data_out = read_bor([db_pth file_name],[],[],Year,[],1);     
         else
            data_out = read_bor([db_pth file_name],8,[],Year,[],1);          
         end
         % end kai*
         assignin('caller',fl_name,data_out);  		%assign variable into calling workspace
         trace_str(i).variableName = file_name;
         trace_str(i).data = data_out;
      catch
         chck = 0;
      end
   end
end

