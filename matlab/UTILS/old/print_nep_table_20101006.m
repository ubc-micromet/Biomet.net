
function print_nep_table(years,siteId,pth_localdb,fid_log);

% prints a table showing NEP, R and GEP for 1999:2008 with and without the
% small gap-filling of NEP (Praveena's fix of 20070826).

%years = 2007:-1:1999;
%siteId = 'BS';

if ~isempty(fid_log)
    fprintf(fid_log,'%5s\n',siteId);
    fprintf(fid_log,'%10s%7s%7s%7s%8s%10s%10s%7s%6s%8s\n','Year','NEP','GEP','R',...
              'NaNs','NEP_new','GEP_new','R_new','NaNs','NEPdiff');
    fprintf(fid_log,'%s\n','----------------------------------------------------------------------------------');
end
disp(sprintf('%5s',siteId));
disp(sprintf('%10s%7s%7s%7s%8s%10s%10s%7s%6s%8s','Year','NEP','GEP','R',...
              'NaNs','NEP_new','GEP_new','R_new','NaNs','NEPdiff'));
disp('----------------------------------------------------------------------------------');
for i=1:length(years)
    % load in nep, gep and resp from database containing traces without
    % the implementation of small gf of nep
    %pth = biomet_path(years(i),siteId); % get local db path from biomet_database_default
    pth = fullfile(pth_localdb,num2str(years(i)),siteId);
    nep = read_bor(fullfile(pth,'clean\thirdstage','nep_filled_with_fits'));
    gep = read_bor(fullfile(pth,'clean\thirdstage','eco_photosynthesis_filled_with_fits'));
    resp = read_bor(fullfile(pth,'clean\thirdstage','eco_respiration_filled_with_fits'));
    nepcum = cumsum(12e-6*30*60*nep(find(~isnan(nep))));
    gepcum = cumsum(12e-6*30*60*gep(find(~isnan(gep))));
    respcum = cumsum(12e-6*30*60*resp(find(~isnan(resp))));
    
    % load in nep, gep and resp from database containing traces with
    % the implementation of small gf of nep
    pth_db = ['\\Annex001\database\' num2str(years(i)) '\' siteId '\'];
    %pth_db = ['\\annex001\clean_db_backups\20080817\database\' num2str(years(i)) '\' siteId '\'];
    nep_db = read_bor(fullfile(pth_db,'clean\thirdstage','nep_filled_with_fits'));
    gep_db = read_bor(fullfile(pth_db,'clean\thirdstage','eco_photosynthesis_filled_with_fits'));
    resp_db = read_bor(fullfile(pth_db,'clean\thirdstage','eco_respiration_filled_with_fits'));
    tv_db = read_bor(fullfile(pth_db,'clean\thirdstage','clean_tv'),8);
    nepcum_db = cumsum(12e-6*30*60*nep_db(find(~isnan(nep_db))));
    gepcum_db = cumsum(12e-6*30*60*gep_db(find(~isnan(gep_db))));
    respcum_db = cumsum(12e-6*30*60*resp_db(find(~isnan(resp_db))));
    numnans = length(find(isnan(nep)));
    numnansdb = length(find(isnan(nep_db)));
    % print outputs in rows of a table
    if ~isempty(fid_log)
        fprintf(fid_log,'%10.0f%7.0f%7.0f%7.0f%8.0f%10.0f%10.0f%7.0f%6.0f%8.0f\n',years(i),nepcum_db(end),gepcum_db(end),respcum_db(end),...
                                            numnansdb,nepcum(end),gepcum(end),respcum(end),numnans,nepcum_db(end)-nepcum(end));
    end
    disp(sprintf('%10.0f%7.0f%7.0f%7.0f%8.0f%10.0f%10.0f%7.0f%6.0f%8.0f',years(i),nepcum_db(end),gepcum_db(end),respcum_db(end),...
                                            numnansdb,nepcum(end),gepcum(end),respcum(end),numnans,nepcum_db(end)-nepcum(end)));
                                       
end