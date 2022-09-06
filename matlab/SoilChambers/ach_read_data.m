function [data_HF,data_HH] = ach_read_data(currentDate,SiteFlag,systemType,DO_NOT_WRITE)
%[data_HF, data_HH] = ach_read_data(currentDate,SiteFlag,systemType,DO_NOT_WRITE)
%
%Function that reads datafiles from automated respiration system dataloggers
%
%Input variables:   currentDate
%                   SiteFlag
%                   systemType, 1 for version 1.0 (CR10 and 21X), 2 for version 2.0 (CR23X)
%
%Output variables:  data_HF, high frequency (5 sec.) data
%                   data_HH, half hour data
%
%(c) dgg                
%Created:  Feb 1, 2005
%Revision: Nov 29, 2005

% Nov 29, 2005
%   - fixed the systemType so it's now site independent
% Mar 30, 2005
%   - fixed bug that loaded currentDate - 1 instead of currentDate for YF
%   site

if ~exist('DO_NOT_WRITE') | isempty(DO_NOT_WRITE)
    DO_NOT_WRITE = 0;
end

if ~exist('systemType') | isempty(systemType)
    systemType = 2;
end

[pthIn, pthOut] = fr_get_local_path;

c = fr_get_init(SiteFlag,currentDate);			%get the init data
DAY = floor(fr_get_doy(currentDate,0));

%load 21X datafiles (searches for a binary version if previously created)
switch systemType
    case 1 
        fileNameDate = FR_DateToFileName(currentDate+0.2); %add 0.2 to currentDate otherwise you get fileName for the previous date
        fileNameDate = fileNameDate(1:6);                                
        MAT_filename = ([fileNameDate '\' fileNameDate '_' ...
                c.chamber.name21x c.chamber.HF_ext]);   %name of 21x Binary data file
        
        if exist([pthIn MAT_filename]) == 2
            fname = ([pthIn MAT_filename]);
            load(fname,'data_21x')
            if exist('data_21x')
                data_HF = data_21x;    
            else
                load(fname,'data_HF')
            end
%Removed Jan 31, 2006 (dgg)
%             if ~exist('data_21x')
%                 load(fname,'data_HF')
%             end
        else
            filename = ([fileNameDate '\' fileNameDate ...
                    '_' c.chamber.name21x '.dat']);              %first try to find a file name yymmdd\yymmdd_cham_21x.dat
            fname = ([pthIn filename]);
            if exist(fname)~=2 
                filename = ([c.chamber.name21x '.' num2str(DAY)]);        %then try cham_21x.DOY
                fname = ([pthIn filename]);
                if exist(fname)~=2                                        %if neither of the files exists report an error
                    error(['File: ' fname ' does not exist!'])
                end
            end
            try
                data_HF = textread(fname,'%f','delimiter',',');
                
                if floor(length(data_HF)/c.chamber.chans_21x) - length(data_HF)/c.chamber.chans_21x ~=0
                    diff1 = diff(data_HF(1:c.chamber.chans_21x:end));
                    ind = find(diff1~=0);
                    ind1 = find(data_HF==167);
                    data_HF1 = [data_HF(1:ind1(ind)-1) ; data_HF(ind1(ind+2):end)];
                end
                
                data_HF = reshape(data_HF,c.chamber.chans_21x, ...
                    length(data_HF)/c.chamber.chans_21x)';
            catch
                disp(['Error during loading of: ' fname ' using "textread".']);
                disp('Trying using dlmreadf.');
                data_HF = dlmreadf(fname);
            end
            if DO_NOT_WRITE == 0
                try
                    fname = ([pthIn MAT_filename]);
                    save(fname,'data_HF')
                catch
                    disp(['Saving of: ' fname ' has failed!'])
                end
            end
        end
        
        %load CR10 datafiles (searches for a binary version if previously created)
        MAT_filename = ([fileNameDate '\' fileNameDate '_' ...
                c.chamber.nameCR10 c.chamber.HF_ext]);       %name of CR10 Binary data file
        
        if exist([pthIn MAT_filename]) == 2 & str2num(fileNameDate) > 830
            fname = ([pthIn MAT_filename]);
            load (fname, 'data_CR10');
            if exist('data_CR10')
                data_HH = data_CR10;    
            else
                load(fname,'data_HH')
            end
%Removed Jan 31, 2006 (dgg)
%             if ~exist('data_CR10')
%                 load (fname, 'data_HH');
%             end
        else
            filename = ([fileNameDate '\' fileNameDate '_' ...
                    c.chamber.nameCR10 '.dat' ]);                     %name of CR10 comma delimited data files
            fname = ([pthIn filename]);
            if exist(fname)~=2 
                filename = ([c.chamber.nameCR10 '.' num2str(DAY)]);      %name of CR10 comma delimited data files
                fname = ([pthIn filename]);
                if exist(fname)~=2                                       %if neither of the files exists report an error
                    error(['File: ' fname ' does not exist!'])
                end
            end
            try
                data_HH = textread(fname,'%f','delimiter',',');
                data_HH = reshape(data_HH,c.chamber.chans_CR10,...
                    length(data_HH)/c.chamber.chans_CR10)';
            catch
                disp(['Error during loading of: ' fname ' using "textread".']);
                disp('Trying using dlmreadf.');
                data_HH = dlmreadf(fname);
            end
            if DO_NOT_WRITE == 0
                try
                    fname = ([pthIn MAT_filename]);
                    save(fname,'data_HH')
                catch
                    disp(['Saving of: ' fname ' has failed!'])
                end
            end
        end    
    case 2
        fileNameDate = FR_DateToFileName(currentDate+0.2);        %add 0.2 to the currentDate otherwise you get fileName for the previous
        fileNameDate = fileNameDate(1:6);                         %date.  Zoran, Mar 30, 2005 
        
        %load HF 23x datafiles  
        data_HF = ach_load_file(fileNameDate,c.chamber.name23x_HF,pthIn,c.chamber.chans_23x_HF,c.chamber.ID_23x_HF);
        
        %load HH 23x datafiles
        data_HH = ach_load_file(fileNameDate,c.chamber.name23x_HH,pthIn,c.chamber.chans_23x_HH,c.chamber.ID_23x_HH);
        
end
