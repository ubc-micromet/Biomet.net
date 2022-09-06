function db_update_berms(pth_db_msc,pth_db,Year,SiteId,extension_in)
% db_update_berms(pth_db_msc,pth_db,Year,SiteId,extension_in)

% Revisions:
% May 03, 2006 - kai*
%   Using db_pth_root for log files, put log files in database
% Apr 21, 2004 - kai*
%    Added extension_in so only specific file types are processed
% Apr  2, 2004 - kai* 
%    Added automatic output directory creation for lowest level directory

switch upper(SiteId)
case {'BS'}
    SiteName = 'PAOB';
case {'JP'}
    SiteName = 'PAOJ';
case {'PA'}
    SiteName = 'PAOA';
otherwise
    SiteName = SiteId;
end

switch upper(SiteId)
case 'BS'
   BermsId = 'obs';
case 'JP'
   BermsId = 'ojp';
case 'PA'
   BermsId = 'oa';
otherwise
   BermsId = lower(SiteName);
end   

[directory extension outdir] = textread(fullfile(pth_db_msc,['files_to_biometDB_' SiteId '.ini']),'%s %s %s','headerlines',1);

if exist('extension_in') & ~isempty(extension_in)
    [ext_dum,ind] = intersect(extension,extension_in);
    directory = directory(ind);
    extension = extension(ind);
    outdir    = outdir(ind);
end

diary(fullfile(db_pth_root,num2str(Year),SiteId,'dbase_BERMS.log'))
disp(sprintf('==============  Start ========================================='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('Variables: '));
disp(sprintf('pthIn = %s',pth_db_msc));
disp(sprintf('pthOut = %s',pth_db));
disp(sprintf('Year = %s',num2str(Year)));
disp(sprintf('SiteId = %s',SiteId));

k = 0;
for i = 1:length(extension)
   try
      EXT = char(extension(i));
      DIR = char(directory(i));
      OUT = char(outdir(i));
      
      pth_in  = fullfile(pth_db_msc,BermsId,DIR);
      pth_out = fullfile(pth_db,num2str(Year),SiteId,'BERMS',OUT);
      if Year<1999
         ind = findstr(pth_out,num2str(1999));
         if ~isempty(ind)
             pth_out(ind:ind+3) = num2str(Year);
         end
      end
      
      berms_out = readbermsdb(Year,pth_in,EXT);
      if ~isempty(berms_out)
         % Create lowet level output directory
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
