function [tv,climateData] = ach_move_and_rename(dateIn,filePathIn,fileName,filePathOut,tableID,timeUnit)
% move and rename temporary chamber system datalogger files 
%  [tv2,climateData2] = ach_move_and_rename(datenum(2005,8,25),...
%                     'D:\met-data\csi_net\chamber_temp','CH_23X_2.DAT','d:\met-data\data\',101,'sec');
% This program will load file: fileName, extract all the data for the
% date dateIn and rename it to yymmdd_fileName and store it 
% in the folder filePathOut.  If filePathOut is not given the program will
% store the data into the data path obtained using fr_get_local_path.
%
% (c) Zoran Nesic           File created:           Sep  1, 2005
%                           Last modification:      Jan 23, 2007
%

% Revisions:
%
%   Jan 23, 2007
%       - added options to process multiple days at the same run.
%           - if dateIn is an array it will loop through all dates
%           - if dateIn is negative it will extract all days older and
%           equal to abs(dateIn)
%	Sep 13, 2005
%		- Program will not anymore write an empty matrix into a file causing
% 		  blank lines to appear in the data. Bug fixed in the fast_csvwrite.
%		  Special case: if data is to be written with 'wt' option - an empty
%		  file will be created (fopen followed by fclose).
%		- Program now writes yymmdd files with append (it will not overwrite).
%		  It still uses overwrite when writing back the dataLeft into *.dat file

% Load data
[tv,climateData] = fr_read_csi(fullfile(filePathIn,fileName),[],[],tableID,0,timeUnit,2);

% Return if there is no data in the file. Print a message on the screen
if isempty(climateData)
   disp(sprintf('File: %s is empty or it does not exist!',fullfile(filePathIn,fileName)));
   return
end
daysInTV = unique(floor(tv(:)));

if dateIn < 0 
    dateIn = abs(dateIn);
    dateIn = daysInTV(find(daysInTV <= dateIn));
end

dateIn = sort(floor(dateIn));

for currentDate = dateIn(:)'
    % Extract the requested date. If date is not present extract all days
    % assuming default folders (this feature is to be added later, first focus
    % on getting one day out of the file).
%    days = unique(floor(dateIn));
%    if length(days) > 1
%        error 'Currently only one day at the time can be renamed and moved!'
%    end
    ind_dateIn = find( ceil(tv) == floor(currentDate)+1 ); % 00:01 to 23:59 (inclusive) belong to the same day

    if ~isempty(ind_dateIn)  % skip if date does not exist
        
        dataOut = climateData(ind_dateIn,:);

        % Store the extracted data under pathOut and yymmdd\yymmdd_fileName name.
        datePath = sprintf('%04d%02d%02d',datevec(currentDate));
        datePath = datePath(3:8);
        dataFolder = fullfile(filePathOut,datePath);
        if ~exist(dataFolder,'dir')
            % create folder if it doesn't exist
            mkdir(filePathOut,datePath);
        end

        % write the data with append 'at'(in case there is some data already there
        % under the same name
        fast_csvwrite(fullfile(dataFolder,[datePath '_' fileName]),dataOut,'at')
        %csvwrite(fullfile(dataFolder,[datePath '_' fileName]),dataOut)

        % if there is more data in the file that belongs for dates after dateIn
        % store the reminder of the data under the original name (keep the csv
        % format too)

        dataLeft = climateData;
        dataLeft(ind_dateIn,:) = [];
        climateData = dataLeft;
        tv(ind_dateIn) = [];
    end % skip if date does not exist
end

% write with overwrite 'wt'
fast_csvwrite(fullfile(filePathIn,fileName),dataLeft,'wt');

%===============================================================

function fast_csvwrite(fileName,dataOut,fileOpenFlag)
% Create a default format for output.  This avoids the need for csvwrite
% wich is very slow.
   
	frmt = ['%d,%d,%d,%d'];
	for i=1:size(dataOut,2)-4;
   	frmt = [frmt ',%g'];
	end;
	frmt = [frmt '\n'];
	fid = fopen(fileName,fileOpenFlag);
	if ~isempty(dataOut)					% write only if there is data to be written
      fprintf(fid,frmt,dataOut');
   end
   fclose(fid);

