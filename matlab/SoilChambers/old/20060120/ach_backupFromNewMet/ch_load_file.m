function data_HF = ch_load_file(fileNameDate,loggerName,pthHF,NumOfChans,tableID)
%
% This is a generic function for loading Chamber system logger files
% It tries to handle all the abnormalities that may happen in a CSI logger file.
% For this function to work there must be a valid and unique tableID available.  
%
%   fileNameDate    -   yymmdd format (string)
%   loggerName      -   logger file name (see c.chamber.namexxxxx variable in the ini file)
%   pthHF           -   path to high frequency data  (output of fr_get_local_path)
%   NumOfChans      -   number of output variables in the file (see c.chamber.chans_xxxx variable in the ini file)
%   tableID         -   table ID is needed so the function can recover data from the files that have rows of data
%                       with incorrect number of channels.  The function looks for tableID to re-establish the
%                       data pattern. * see the NOTE below *
%
%   data_HF         -   an empty matrix if there is an error, otherwise it contains the HF data
%
% NOTE: If there is a problem in a file whose tableID is matching the DOY (or some other integer in the file), this
%       function will not be able to re-establish the pattern.  Further improvements could be made by introducing
%       a two-byte patterns (tableID + Year) but that would make my head hurt. :-)
%
% (c) Zoran Nesic           File created:       Sep 30, 2002
%                           Last modification:  Sep 30, 2002

% Revisions:


data_HF = [];

filename = ([fileNameDate '\' fileNameDate ...
                  '_' loggerName '.dat']);        %first try to find a file name yymmdd\yymmdd_cham_21x.dat
fname = ([pthHF filename]);
if exist(fname)~=2 
   error(['File: ' fname ' does not exist!'])
end

try
    data_HF = textread(fname,'%f','delimiter',',');
    % if [N,1]=size(data_HF) and N/NumOfChans is not an integer
    % the raw data file's been corrupted. Try to find and remove the
    % lines of data with errors in them
    ind1 = find(data_HF==tableID);
    if ind1(1)~=1                                       % make sure file starts with tableID
        data_HF = data_HF(ind1(1):end);                 % skip until the first valid tableID
        ind1 = find(data_HF==tableID);                  % update ind1
    end
    while ~all(data_HF(1:NumOfChans:end)==tableID)
        diff1 = diff(data_HF(1:NumOfChans:end));
        ind = find(diff1~=0);                           % find all errors in the file
        ind = ind(1);                                   % fix one error at the time
        data_HF = [data_HF(1:ind1(ind)-1) ; data_HF(ind1(ind+2):end)];
        ind1 = find(data_HF==tableID);
    end
    N = floor(length(data_HF)/NumOfChans);
    data_HF = reshape(data_HF(1:N*NumOfChans),NumOfChans,N)';
catch
    disp(['Error during loading of: ' fname ' using "textread".']);
    disp('Returning an empty array.');
    data_HF = [];
end
