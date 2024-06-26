function [k,StatsAll,dbFileNames, dbFieldNames,errCode] = db_new_eddy(arg1,wildcard,pthOut,verbose_flag,excludeSubStructures,timeUnit,missingPointValue)
%
% eg. k = db_new_eddy('\\annex001\database\2000\cr\flux\raw\',
%                             '0001*.hp.mat','\\annex001\database\2000\cr\flux\');
%       would update the data base using all Jan 2000 files
%
%   This function updates eddy correlation (PC based) data base files.
%   It reads data from hhour files stored in the pthIn directory and
%   updates data base located in pthOut
%   
%   If argument Arg1 is any structure with a field Arg1().TimeVector it
%   will be stored too as a set of data base files
%   
%   Wildcard parameter lets us choose the site (hp or hc)
% 
% Inputs:
%       arg1        -   raw data path (*.mat files) or an actual data
%                       structure
%       wildcard    -   '*.hp.mat' or '*.hc.mat'
%       pthOut      -   data base location for the output data
%       verbose_flag - 1 -ON, otherwise OFF
%       excludeSubStructures - cell array or a string with names or a name
%       of the substructure within Stats or HHour that should not be
%       processed.  Setting excludeSubStructures to 'DataHF' will remove
%       the high frequency data from the ACS data set.
%       timeUnit    - minutes in the sample period (spacing between two
%                     consecutive data points. Default 30 (hhour)
% Outputs:
%       k           -   number of files processed
%
% (c) Zoran Nesic               File created:       Apr  1, 2004
%                               Last modification:  Oct  4, 2023

% Revisions:
%
%   Oct 4, 2023 (Zoran)
%    - added errCode to the output parameters. It can then be used to verify
%      if the progress list should be updated (everything went OK) or not 
%      (there were errors in data saving).
%   Sep 6, 2023 (Zoran)
%    - It's now possible to create database with any time resolution in minutes.
%      If timeUnit == 3, data base will have resolution of 3 minutes. (search for 20230906)
%   July 26, 2023 (Zoran)
%    - Converted a few '\' into filesep to keep the program compatible with MacOS
%
%   July 27, 2022 (Zoran)
%       - changed Clean_tv into clean_tv
%   July 26, 2022 (Zoran)
%       - added an option to convert a double underline '__' to '.'. To be
%       used when this function needs to replicate dbase_update output.
%   June  8, 2020 (Zoran)
%       - fixed message display on the screen (added \n)
%   Oct 20, 2019 (Zoran)
%       - missing point value can now be change using missingPointValue
%       variable.  Default is 0 but for the newer sites we should use NaN.
%   Jan 08, 2010 (Nick)
%       - modified the test to check that all data is from the same year so
%       that "timeUnit" is used rather than a hard-coded value of 29
%       minutes; update was failing for 10 minute datasets
%   Aug 12, 2009 (z)
%       - added option to create data base of the structures whose data
%       points are not 30 minute separated. timeUnit variable is used and
%       its default is 30 (30-minute period or hhour).
%   Oct 15, 2008
%      - Nick moved legacy version of db_new_eddy to an internal function
%   Feb 11, 2008
%      - fixed the bug that caused a NaN in tv to propagate and caused 
%        arrays to go over 1-year boundaries (added extra points to a
%        database trace).  Added test for isfinite(tv).
%   Nov 8, 2007
%       - Changed the way we load the stats structure to make it
%       structure-name independent (see tempStats in the program)
%       - Added an option to remove a part of the structure before
%       proceeding with the data base update.  The cell array
%       excludeSubStructures contains the names of all substructures that
%       need to be excluded.  Example (for ACS data): 
%       excludeSubStructures = 'DataHF'
%       would exclude high frequency data that we don't want to store.
%   Sep 12, 2005
%       - fixed a bug where, if the data did not come in a series of
%       consecutive points (indTv was not incrementing by 1), the data
%       would be written into consecutive (wrong) locations. See saveAll
%       function
%  June 19, 2005
%       - function now creates path if the destination path does not exist
%       - added storing of a copy of TimeVector in Clean_tv trace to
%         provide compatibility with database handling software that needs
%         the clean_tv trace
%  June 16, 2005
%       - added verbose_flag
%       - changed help lines to reflect dual function of Arg1 (Zoran)
%       - fixed bug that created an error message when Arg1 was a structure
%       ("??? One or more output arguments not assigned during call to
%       'db_new_eddy'.")
% Nov 05, 2004 - kai* & Joe
% Fixed error on assignment of dissimilar structures by ordering fields in 
% all structures read from half-hour files and testing for differences in
% field names.
% Sep 09, 2004 - kai* & Christopher
% Fixed 'spanning two year' error message popping up for every Dec 31. 
% Aug 11, 2004 - kai*,Praveena,Chirstoper
% Changed arguments to be able to hand over the Stats structure OR the path
% from where they will be loaded.
%

% takes care of legacy issues
if nargin == 4
    [k,StatsAll,dbFileNames, dbFieldNames] = db_new_eddy_old(arg1,wildcard,pthOut,verbose_flag);
end

arg_default('verbose_flag',1);              % default 1 (ON)
arg_default('excludeSubStructures',[]);     % default exclude none
arg_default('timeUnit',30);                 % default is 30 minutes
arg_default('missingPointValue',0);         % default is 0 (legacy Biomet value). Newer setups should use NaN

if ischar(arg1)
   pth_tmp = fr_valid_path_name(arg1);          % check the path and create
   if isempty(pth_tmp)                         
      error (sprintf('Directory %s does not exist!',arg1));
   else
      pthIn = pth_tmp;
   end
else
   StatsAll = arg1;
end

startTime = now;

pth_tmp = fr_valid_path_name(pthOut);          % check the path and create
if isempty(pth_tmp)                         
   fprintf(1,'Directory %s does not exist!... ',pthOut);
   fprintf(1,'Creating new folder!... ');
   indDrive = find(pthOut == filesep);
   [successFlag] = mkdir(pthOut(1:indDrive(1)),pthOut(indDrive(1)+1:end));
   if successFlag
       fprintf(1,'New folder created!\n');
   else
       fprintf(1,'Error creating folder!\n');
       error('Error creating folder!');
   end
else
   pthOut = pth_tmp;
end

k = 0;
if exist('pthIn')
   % load all files and join them
   D = dir([pthIn wildcard]);
   n = length(D);
   tic;
   StatsAll = [];
   for i=1:n
      %if D(i).isdir == 0 & ~strcmp(D(i).name(7),'s')       % avoid directories and short form hhour files
      if D(i).isdir == 0        % avoid directories, use short form hhour files (Jan 18, 2000)
         if find(D(i).name == ':' | D(i).name == filesep) 
            tempStats = load(D(i).name);
         else
            tempStats = load([pthIn D(i).name]);
         end
         Stats = tempStats.(char(fields(tempStats)));
         Stats = ubc_orderfields(Stats);
         
         if length(StatsAll) == 0
            StatsAll = Stats;
         else
            try
               % Test for differences in field names
               fieldsStats = fieldnames(Stats);
               fieldsStatsAll = fieldnames(StatsAll);
               diff1 = setdiff(fieldsStats,fieldsStatsAll);
               diff2 = setdiff(fieldsStatsAll,fieldsStats);
               
               % Fix differences
               if ~isempty(diff1)
                  for l = 1:length(diff1)
                     eval(['StatsAll(1).' char(diff1(l)) ' = [];']);
                  end
                  StatsAll = ubc_orderfields(StatsAll);
               end
               
               if ~isempty(diff2)
                  for l = 1:length(diff2)
                     eval(['Stats(1).' char(diff2(l)) ' = [];']);
                  end
                  Stats = ubc_orderfields(Stats);
               end               
               
               % Assemble structure
               StatsAll(length(StatsAll)+1:length(StatsAll)+length(Stats)) = Stats;
            catch
               disp(lasterr);
            end
         end
         fprintf('Processing: %s ...  ',D(i).name)
         k = k+1;
      end
   end
   tm = toc;
   if verbose_flag,fprintf(1,'%d files loaded in %4.3f seconds.\n',([k tm]));end
end

% Remove any topmost fields that don't need to be converted to the data
% base format:
if ~isempty(excludeSubStructures)
    StatsAll = rmfield(StatsAll,excludeSubStructures);
end

%
% extract the time vector and index it to the current year
%
tic;
tv = get_stats_field(StatsAll,'TimeVector');
%
% Keep only tv that are numbers
% (added Feb 11, 2008)
ind_finite = find(isfinite(tv));
StatsAll = StatsAll(ind_finite);
tv = tv(ind_finite);
%
% Remove all tv==0 values
ind_not_zeros = find(tv~=0);
StatsAll = StatsAll(ind_not_zeros);
tv = tv(ind_not_zeros);

% Make sure there are no duplicate entries.
[tv,IA]=unique(tv);
StatsAll = StatsAll(IA);

% Sort the time vector (there is no guarantee that the files will be 
% loaded in any particular order so we have to assume that the dates
% are mixed up.
[tv,ind] = sort(tv);
% sort the entire structure accordingly
StatsAll = StatsAll(ind);
% make sure all the files belong to the same year, don't do anything if 
% they don't belong to the same year
year1 = datevec(tv(1));

%ind = find(tv < datenum(year1(1),1,1,0,29,0) | tv > datenum(year1(1)+1,1,1,0,1,0));

ind = find(tv < datenum(year1(1),1,1,0,timeUnit-1,0) | tv > datenum(year1(1)+1,1,1,0,1,0)); % Jan 08, 2010

if ~isempty(ind)
   error ('Data belongs to two (or more) different years! Only one year can be processed.  Program stopped!')
end
% create a time vector for the year (all half hours)
% and find where the data belongs
nDays = datenum(year1(1)+1,1,1) - datenum(year1(1),1,1);
fullYearTv = datenum(year1(1),1,1,0,timeUnit:timeUnit:nDays*24*60,0)';
% 20230906 - 
%     Made time resolution more generic. Instead of using timeUnit == 30 or == 1 
%     timeUnit can now be generic (see fr_round_time). 
%     
% if timeUnit == 30
%     [junk,indTv] = intersect(fr_round_time(fullYearTv,'30min',1),fr_round_time(tv,'30min',1));
%     % intersect(fr_round_hhour(fullYearTv),fr_round_hhour(tv));
% else
%     % assume that timeUnit is in minutes (which is what it should be)
%     [junk,indTv] = intersect(fr_round_time(fullYearTv,'min',1),fr_round_time(tv,'min',1));
% end
%

% Create strTimeUnit instead of using the if-else that's commended out above.
strTimeUnit = sprintf('%dmin',timeUnit);
[~,indTv] = intersect(fr_round_time(fullYearTv,strTimeUnit,1),fr_round_time(tv,strTimeUnit,1));

%--------------------------------------------------------------------------------
% Start storing the variables, first analyze the ones we know are 
% always there, then go for the generic names
%--------------------------------------------------------------------------------

% Dec 13, 2011: test length of StatsAll... if this is a CSI .DAT file it could contain
% only one hhour, this crashed previous version of code.

% for l = 2:length(StatsAll) % Skip the first entry since it contain Configuration
%     dum = StatsAll(l);
%     s(l) = whos('dum'); 
% end
% [dum,i_max] = max([s(:).bytes]);

if length(StatsAll)>=2
    for l = 2:length(StatsAll) % Skip the first entry since it contains Configuration if data extracted from a flux file
        dum = StatsAll(l);
        s(l) = whos('dum');
    end
    [dum,i_max] = max([s(:).bytes]);
    dbFileNamesTmp = recursiveStrucFieldNames(StatsAll,i_max+1);
else % we have only one hhour to process
    dum = StatsAll(1);
    s(1) = whos('dum');
    %[dum,i_max] = max([s(:).bytes]);
    dbFileNamesTmp = recursiveStrucFieldNames(StatsAll,1);
end

%dbFileNamesTmp = recursiveStrucFieldNames(StatsAll,i_max+1);
nFiles = length(dbFileNamesTmp);
dbFileNames = [];
dbFieldNames = [];
for i=1:nFiles
   % create file and field namesnames
   fieldName = char(dbFileNamesTmp(i));
   [fileNameX] = replaceControlCodes(fieldName);
   dbFileNames{i}=fullfile(pthOut,fileNameX);
   dbFieldNames{i} = fieldName;
end
% Save the data
errCode = saveAll(StatsAll,dbFileNames,dbFieldNames,fullYearTv,indTv,missingPointValue);
% report time
tm = toc;
if errCode ~= 0 
   fprintf('***  %d errors during processing. ***\n',errCode);
end

if exist('pthIn')
   if verbose_flag,fprintf('%d files processed in %4.3f seconds.\n',([k tm]));end
else
   if verbose_flag,fprintf('%i database entries generated in %4.3f seconds.\n',([length(StatsAll) tm]));end
end



%===============================================================
%
% Save all files
%
%===============================================================
function errCode = saveAll(Stats,fileNamesIn,fieldNamesIn,fullYearTv,indTv,missingPointValue)

errCode = 0;
for i=1:length(fileNamesIn)
   fileName = char(fileNamesIn(i));
   fieldName = char(fieldNamesIn(i));
   try
       dataIn = get_stats_field(Stats,fieldName);
       if ~isempty(dataIn)
          if ~exist(fileName,'file')
             % if the file doesn't exist  
             % create it (dbase initialization)
             % special handling of TimeVector (always store full year)
             % in double precision
             % Also create clean_tv == TimeVector to provide compatibility with
             % database reading programs (Zoran, June 19, 2005)
             if ~isempty(findstr(fileName,'TimeVector'))
                save_bor(fileName,8,fullYearTv);
                ind = findstr(fileName,'TimeVector');
                save_bor([fileName(1:ind-1) 'clean_tv'],8,fullYearTv);
             elseif ~isempty(findstr(fileName,'RecalcTime'))
                dataTemp = missingPointValue * zeros(size(fullYearTv));
                dataTemp(indTv) = dataIn;
                save_bor(fileName,8,dataTemp);
             else
                dataTemp = missingPointValue * zeros(size(fullYearTv));
                dataTemp(indTv) = dataIn;
                save_bor(fileName,1,dataTemp);                
             end
          else 
             % if file already exist just write the new data at the
             % proper spot
             if isempty(findstr(fileName,'TimeVector'))
                if ~isempty(findstr(fileName,'RecalcTime'))
                   jumpInd = 8;
                   formatX = 'float64';
                else
                   jumpInd = 4;
                   formatX = 'float32';
                end % findstr(fileName,'RecalcTime')
                fid = fopen(fileName,'rb+');
                if fid ~= -1
                    % First make sure the index has consecutive points only
                    if all(diff(indTv)== 1)
                        % if they are consecutive use the fast saving option
                        status = fseek(fid,jumpInd*(indTv(1)-1),'bof');
                        if status == 0
                            status = fwrite(fid,dataIn,formatX); 
                        else
                            disp('Error doing FSEEK')
                            errCode = errCode + 1;
                        end
                    else
                        % if not, use the slow way
                        for countIndTv = 1:length(indTv)
                           status = fseek(fid,jumpInd*(indTv(countIndTv)-1),'bof');
                           if status == 0
                                status = fwrite(fid,dataIn(countIndTv),formatX); 
                           else
                                disp('Error doing FSEEK')
                                errCode = errCode + 1;
                           end
                        end
                    end
                else
                   disp(['Error opening: ' fileName]);
                   errCode = errCode + 1;
                end
                fclose(fid);                
             end % ~findstr(fileName,'TimeVector')
          end % ~exist(fileName,'file')
       end % ~isempty(dataIn)
   catch
       disp(['Error while processing: ' fieldName]);
       errCode = errCode + 1;
   end %try
end % i=1:length(fileNamesIn)
%end % of function

%===============================================================
%
% replace control codes
%
%===============================================================

function [fileName] = replaceControlCodes(oldName)
% replace all the brackets and commas using the following table
% '('  -> '_'
% ','  -> '_'
% ')'  -> []
% '__' -> '.'
ind = strfind(oldName,'__' );
if length(ind)==1   % the special code of '__' works only if there is only one in the name
    oldName = [oldName(1:ind-1) '.' oldName(ind+2:end)];
end
ind = find(oldName == '(' | oldName == ',');
oldName(ind) = '_';
ind = find(oldName == ')');
oldName(ind) = [];
fileName = oldName;

%end % of function


%===============================================================
%
% Recursive structure field name search
%
%===============================================================

function dbFileNames = recursiveStrucFieldNames(StatsAll,n_template)
arg_default('n_template',1);
dbFileNames = [];
nFiles = 0;
statsFieldNames = fieldnames(StatsAll);
for i = 1:length(statsFieldNames)
   fName = char(statsFieldNames(i));
   % load the first element of StatsAll to 
   % examine the structure type
   fieldTmp = getfield(StatsAll,{n_template},fName);
   % skip fields 'Configuration', 'Spectra' and all character and cell fields
   if ~strcmp(fName,'Configuration') & ~ischar(fieldTmp) & ~iscell(fieldTmp) & ~strcmp(fName,'Spectra')
      % is it a vector or not
      nLen = length(fieldTmp);
      if nLen > 1
         [nCol, nRow] = size(fieldTmp);
         for j = 1:nCol
            for j1 = 1:nRow
               nFiles = nFiles + 1;
               if nCol == 1 | nRow == 1 
                  % if it's a one dimensional vector use only one index
                  jj = max(j,j1);
                  dbFileNames{nFiles} = [fName '(' num2str(jj) ')' ];
               else
                  % for two dimensional vectors use two 
                  dbFileNames{nFiles} = [fName '(' num2str(j) ',' num2str(j1) ')' ];
               end % if nCol == 1 or nRow == 1 
               % test if it's a structure and do a recursive call
               if isstruct(fieldTmp)
                  %-------------------------
                  % recursive call goes here
                  %-------------------------
                  %                    fieldI = get_stats_field(StatsAll,fName);
                  if nCol == 1 | nRow == 1 
                     % if it's a one dimensional vector use only one index
                     jj = max(j,j1);
                     dbFileNamesTmp = recursiveStrucFieldNames(fieldTmp(jj));
                  else
                     % for two dimensional vectors use two 
                     dbFileNamesTmp = recursiveStrucFieldNames(fieldTmp(j,j1));
                  end % if nCol == 1 or nRow == 1 
                  
                  mFiles = length(dbFileNamesTmp);
                  dbFileNamesBase = char(dbFileNames{nFiles});
                  % move the pointer back to overwrite the last entry
                  nFiles = nFiles - 1;                            
                  for k=1:mFiles
                     nFiles = nFiles + 1;
                     dbFileNames{nFiles}=[dbFileNamesBase '.' char(dbFileNamesTmp(k))];
                  end % i=1:nFiles
               end % if isstruc(fieldTmp)
            end % for j1=1:nRow
         end % j = 1:nCol
      else
         % save new file name
         nFiles = nFiles + 1;
         dbFileNames{nFiles} = fName;
         % test if it's a structure and do a recursive call
         if isstruct(fieldTmp)
            %-------------------------
            % recursive call goes here
            %-------------------------
            %                    fieldI = get_stats_field(StatsAll,fName);
            dbFileNamesTmp = recursiveStrucFieldNames(fieldTmp);
            mFiles = length(dbFileNamesTmp);
            dbFileNamesBase = char(dbFileNames{nFiles});
            % back out the index by one (over-write the last fName entry)
            nFiles = nFiles - 1;
            for k=1:mFiles
               nFiles = nFiles + 1;
               dbFileNames{nFiles}=[dbFileNamesBase '.' char(dbFileNamesTmp(k))];
            end % i=1:nFiles
         end % if isstruc(fieldTmp)
      end % nLen > 1
   end % fName ~= 'Configuration'
end % for i = 


function [k,StatsAll,dbFileNames, dbFieldNames] = db_new_eddy_old(arg1,wildcard,pthOut,verbose_flag)
%
% eg. k = db_new_eddy('\\annex001\database\2000\cr\flux\raw\',
%                             '0001*.hp.mat','\\annex001\database\2000\cr\flux\');
%       would update the data base using all Jan 2000 files
%
%   This function updates eddy correlation (PC based) data base files.
%   It reads data from hhour files stored in the pthIn directory and
%   updates data base located in pthOut
%   
%   If argument Arg1 is any structure with a field Arg1().TimeVector it
%   will be stored too as a set of data base files
%   
%   Wildcard parameter lets us choose the site (hp or hc)
% 
% Inputs:
%       arg1        -   raw data path (*.mat files) or an actual data
%                       structure
%       wildcard    -   '*.hp.mat' or '*.hc.mat'
%       pthOut      -   data base location for the output data
%       verbose_flag - 1 -ON, otherwise OFF
% Outputs:
%       k           -   number of files processed
%
% (c) Zoran Nesic               File created:       Apr  1, 2004
%                               Last modification:  Sep 12, 2005

% Revisions:
%   Sep 12, 2005
%       - fixed a bug where, if the data did not come in a series of
%       consecutive points (indTv was not incrementing by 1), the data
%       would be written into consecutive (wrong) locations. See saveAll
%       function
%  June 19, 2005
%       - function now creates path if the destination path does not exist
%       - added storing of a copy of TimeVector in Clean_tv trace to
%         provide compatibility with database handling software that needs
%         the clean_tv trace
%  June 16, 2005
%       - added verbose_flag
%       - changed help lines to reflect dual function of Arg1 (Zoran)
%       - fixed bug that created an error message when Arg1 was a structure
%       ("??? One or more output arguments not assigned during call to
%       'db_new_eddy'.")
% Nov 05, 2004 - kai* & Joe
% Fixed error on assignment of dissimilar structures by ordering fields in 
% all structures read from half-hour files and testing for differences in
% field names.
% Sep 09, 2004 - kai* & Christopher
% Fixed 'spanning two year' error message popping up for every Dec 31. 
% Aug 11, 2004 - kai*,Praveena,Chirstoper
% Changed arguments to be able to hand over the Stats structure OR the path
% from where they will be loaded.
%

if ~exist('verbose_flag') | isempty(verbose_flag)
    verbose_flag = 1;
end

if ischar(arg1)
   pth_tmp = fr_valid_path_name(arg1);          % check the path and create
   if isempty(pth_tmp)                         
      error (sprintf('Directory %s does not exist!',arg1));
   else
      pthIn = pth_tmp;
   end
else
   StatsAll = arg1;
end

pth_tmp = fr_valid_path_name(pthOut);          % check the path and create
if isempty(pth_tmp)                         
   fprintf(1,'Directory %s does not exist!... ',pthOut);
   fprintf(1,'Creating new folder!... ');
   indDrive = find(pthOut == filesep);
   [successFlag] = mkdir(pthOut(1:indDrive(1)),pthOut(indDrive(1)+1:end));
   if successFlag
       fprintf(1,'New folder created!\n');
   else
       fprintf(1,'Error creating folder!\n');
       error('Error creating folder!');
   end
else
   pthOut = pth_tmp;
end

k = 0;
if exist('pthIn')
   % load all files and join them
   D = dir([pthIn wildcard]);
   n = length(D);
   tic;
   StatsAll = [];
   for i=1:n
      %if D(i).isdir == 0 & ~strcmp(D(i).name(7),'s')       % avoid directories and short form hhour files
      if D(i).isdir == 0        % avoid directories, use short form hhour files (Jan 18, 2000)
         if find(D(i).name == ':' | D(i).name == filesep) 
            load(D(i).name);
         else
            load([pthIn D(i).name]);
         end
         Stats = ubc_orderfields(Stats);
         
         if length(StatsAll) == 0
            StatsAll = Stats;
         else
            try
               % Test for differences in field names
               fieldsStats = fieldnames(Stats);
               fieldsStatsAll = fieldnames(StatsAll);
               diff1 = setdiff(fieldsStats,fieldsStatsAll);
               diff2 = setdiff(fieldsStatsAll,fieldsStats);
               
               % Fix differences
               if ~isempty(diff1)
                  for l = 1:length(diff1)
                     eval(['StatsAll(1).' char(diff1(l)) ' = [];']);
                  end
                  StatsAll = ubc_orderfields(StatsAll);
               end
               
               if ~isempty(diff2)
                  for l = 1:length(diff2)
                     eval(['Stats(1).' char(diff2(l)) ' = [];']);
                  end
                  Stats = ubc_orderfields(Stats);
               end               
               
               % Assemble structure
               StatsAll(length(StatsAll)+1:length(StatsAll)+length(Stats)) = Stats;
            catch
               disp(lasterr);
            end
         end
         disp(sprintf('Processing: %s',D(i).name))
         k = k+1;
      end
   end
   tm = toc;
   if verbose_flag,fprintf(1,'%d files loaded in %4.3f seconds.\n',([k tm]));end
end

%
% extract the time vector and index it to the current year
%
tic;
tv = get_stats_field(StatsAll,'TimeVector');
% Sort the time vector (there is no guarantee that the files will be 
% loaded in any particular order so we have to assume that the dates
% are mixed up.
[tv,ind] = sort(tv);
% sort the entire structure accordingly
StatsAll = StatsAll(ind);
% make sure all the files belong to the same year, don't do anything if 
% they don't belong to the same year
year1 = datevec(tv(1));


if ~isempty(tv < datenum(year1(1),1,1,0,29,0) | tv > datenum(year1(1)+1,1,1,0,1,0))
   error ('Data belongs to two (or more) different years! Only one year can be processed.  Program stopped!')
end
% create a time vector for the year (all half hours)
% and find where the data belongs
nDays = datenum(year1(1)+1,1,1) - datenum(year1(1),1,1);
fullYearTv = datenum(year1(1),1,1,0,timeUnit:timeUnit:nDays*timeUnit*48,0)';
[junk,indTv] = intersect(fr_round_hhour(fullYearTv),fr_round_hhour(tv));
%
%--------------------------------------------------------------------------------
% Start storing the variables, first analyze the ones we know are 
% always there, then go for the generic names
%--------------------------------------------------------------------------------
for l = 2:length(StatsAll) % Skip the first entry since it contain Configuration
    dum = StatsAll(l);
    s(l) = whos('dum'); 
end
[dum,i_max] = max([s(:).bytes]);

dbFileNamesTmp = recursiveStrucFieldNames(StatsAll,i_max+1);
nFiles = length(dbFileNamesTmp);
dbFileNames = [];
dbFieldNames = [];
for i=1:nFiles
   % create file and field namesnames
   fieldName = char(dbFileNamesTmp(i));
   [fileNameX] = replaceControlCodes1(fieldName);
   dbFileNames{i}=fullfile(pthOut,fileNameX);
   dbFieldNames{i} = fieldName;
end
% Save the data
errCode = saveAll(StatsAll,dbFileNames,dbFieldNames,fullYearTv,indTv);
% report time
tm = toc;
if errCode ~= 0 
   disp(sprintf('***  %d errors during processing. ***',errCode));
end

if exist('pthIn')
   if verbose_flag,fprintf(1,'%d files processed in %s.',k, datestr(now-startTime,13));end
else
   if verbose_flag,fprintf(1,'%i database entries generated in %4.3f seconds.',([length(StatsAll) tm]));end
end

 