function db_update_bermsLAI(pth_db_msc,pth_db,Year)
% This function is now obsolete because the creation of non-existing output
% directories has been incorporated into db_update_berms.
%
% Also see \\annex001\projects\BERMS\DOC\BERMS_climate_to_UBC_database.txt
% and 
% \\annex001\projects\BERMS\DOC\AddStagesToBERMSClimateInUBCDatabase.txt
% on how new climate data is incorporated in the database

% The yyyy\pa\berms\laiN directory contains the extraction from the *.LAIN file
% Currently, *.LAI, *.LAI5 and *.LAI6 are used, but as Alan Barr comes up with new
% methods for calculating LAI this might have to be extended.

SiteId = 'PA';
SiteName = 'PAOA';
BermsId = 'oa';

[directory extension outdir] = textread(fullfile(pth_db_msc,['files_to_biometDB_' SiteId '.ini']),'%s %s %s','headerlines',1);

diary(['\\paoa001\Sites\' SiteName '\dbase_BERMS.log'])
disp(sprintf('==============  Start ========================================='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('Variables: '));
disp(sprintf('pthIn = %s',pth_db_msc));
disp(sprintf('pthOut = %s',pth_db));
disp(sprintf('Year = %s',num2str(Year)));
disp(sprintf('SiteId = %s',SiteId));

ind = find(strncmp(upper(extension),'.LAI',4));
extension = extension(ind);
directory = directory(ind);
outdir = outdir(ind);

k = 0;
for i = 1:length(extension)
   try
      EXT = char(extension(i));
      DIR = char(directory(i));
      OUT = char(outdir(i));
      
      pth_in  = fullfile(pth_db_msc,BermsId,DIR);
      pth_out = fullfile(pth_db,num2str(Year),SiteId,'BERMS',OUT);

      berms_out = readbermsdb(Year,pth_in,EXT);
      if ~isempty(berms_out)
          % Create lowet level output directory if it does not exist
          if exist(pth_out) ~= 7
                mkdir(fullfile(pth_db,num2str(Year),SiteId,'BERMS'),OUT);
                disp(['Created ' pth_out]);
          end

         disp(['Exporting to ' pth_out]);
         export(berms_out,pth_out);
         k = k+1;
      else
         disp(['No *' EXT ' data found']);
      end
   catch
      disp(lasterr)      
   end
end

disp(sprintf('Number of paths processed = %d',k));
disp(sprintf('==============  End    ========================================='));
disp(sprintf(''));
diary off
