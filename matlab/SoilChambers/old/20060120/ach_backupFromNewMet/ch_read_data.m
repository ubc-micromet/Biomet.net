function [data_HF, data_HH] = ch_read_data(currentDate,SiteID,DO_NOT_WRITE)
% Created by Gordon Drewitt
% Revisions:
%  - Sep 30, 2002, new function for reading data files. Implemented for OJP only (will do the other sites
%    later. No more *.mat files and dlmread file reading for OJP. (Zoran)
%  - April 17 2002, new constraint on line 68 = str2num(fileNameDate) > 830 (David)
%  - March 11 2002, changed c.chambers.chans_21x and c.chambers.chans_CR10 to
%                           c.chamber.chans_21x and c.chamber.chans_CR10 (lines 41 and 81) (David)

if ~exist('DO_NOT_WRITE') | isempty(DO_NOT_WRITE)
    DO_NOT_WRITE = 0;
end

[pthHF, pthHH] = fr_get_local_path;

c = fr_get_init(SiteID,currentDate);                               %get the init data
DAY = floor(fr_get_doy(currentDate,0));

if upper(SiteID) == 'PA' | upper(SiteID) == 'BS'
   % --- loads 21X datafiles (searches for a binary version if previously created) ---

   fileNameDate = FR_DateToFileName(currentDate);
   fileNameDate = fileNameDate(1:6);
   MAT_filename = ([fileNameDate '\' fileNameDate '_' ...
                           c.chamber.name21x c.chamber.HF_ext]);   %name of 21x Binary data file

   if exist([pthHF MAT_filename]) == 2
      fname = ([pthHF MAT_filename]);
      try
      load(fname,'data_21x')
      catch
      load(fname,'data_HF')
      end
   else
      filename = ([fileNameDate '\' fileNameDate ...
                      '_' c.chamber.name21x '.dat']);              %first try to find a file name yymmdd\yymmdd_cham_21x.dat
      fname = ([pthHF filename]);
      if exist(fname)~=2 
         filename = ([c.chamber.name21x '.' num2str(DAY)]);        %then try cham_21x.DOY
         fname = ([pthHF filename]);
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
             fname = ([pthHF MAT_filename]);
             save(fname,'data_HF')
         catch
             disp(['Saving of: ' fname ' has failed!'])
         end
      end
   end

% --- loads CR10 datafiles (searches for a binary version if previously created) ---

  MAT_filename = ([fileNameDate '\' fileNameDate '_' ...
                       c.chamber.nameCR10 c.chamber.HF_ext]);       %name of CR10 Binary data file

  % David 2002.04.17 - new constraint = str2num(fileNameDate) > 830
  if exist([pthHF MAT_filename]) == 2 & str2num(fileNameDate) > 830
      fname = ([pthHF MAT_filename]);
      try
      load (fname, 'data_CR10');
      catch
      load (fname, 'data_HH');
      end
  else
      filename = ([fileNameDate '\' fileNameDate '_' ...
                c.chamber.nameCR10 '.dat' ]);                     %name of CR10 comma delimited data files
      fname = ([pthHF filename]);
      if exist(fname)~=2 
         filename = ([c.chamber.nameCR10 '.' num2str(DAY)]);      %name of CR10 comma delimited data files
         fname = ([pthHF filename]);
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
             fname = ([pthHF MAT_filename]);
             save(fname,'data_HH')
         catch
             disp(['Saving of: ' fname ' has failed!'])
         end
      end
   end

% ---

elseif upper(SiteID) == 'JP'                % if SiteID == JP

  fileNameDate = FR_DateToFileName(currentDate);
  fileNameDate = fileNameDate(1:6);

  % --- loads HF 23x datafiles  ---  
  data_HF = ch_load_file(fileNameDate,c.chamber.name23x_HF,pthHF,c.chamber.chans_23x_HF,167);

  % --- loads HH 23x datafiles  ---
  data_HH = ch_load_file(fileNameDate,c.chamber.name23x_HH,pthHF,c.chamber.chans_23x_HH,166);

end

% --- makes all the files the same --- (David)

if exist('data_21x')
   data_HF = data_21x;
end

if exist('data_CR10')
   data_HH = data_CR10;
end
