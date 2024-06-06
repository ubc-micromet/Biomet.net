function print_nep_table(yearsIn,siteId,pth_localdb,pth_refdb,fid_log)

% prints a table showing NEP, R and GEP for 1999:2008 with and without the
% small gap-filling of NEP (Praveena's fix of 20070826).

%years = 2007:-1:1999;
%siteId = 'BS';

yearsIn = sort(yearsIn,'descend');

if ~isempty(fid_log)
    fprintf(fid_log,'%5s\n',siteId);
    fprintf(fid_log,'%10s%7s%7s%7s%8s%10s%10s%7s%6s%8s\n','Year','NEP','GEP','R',...
              'NaNs','NEP_new','GEP_new','R_new','NaNs','NEPdiff');
    fprintf(fid_log,'%s\n','----------------------------------------------------------------------------------');
end
fprintf('%5s\n',siteId);
fprintf('%10s%7s%7s%7s%8s%10s%10s%7s%6s%8s\n','Year','NEP','GEP','R',...
              'NaNs','NEP_new','GEP_new','R_new','NaNs','NEPdiff');
disp('----------------------------------------------------------------------------------');
for cntYears=1:length(yearsIn)
    % load in nep, gep and resp from database containing traces without
    % the implementation of small gf of nep
    %pth = biomet_path(years(i),siteId); % get local db path from biomet_database_default
    pth = fullfile(pth_localdb,num2str(yearsIn(cntYears)),siteId);
    try
        if ismember(siteId,{'MPB1' 'MPB2' 'MPB3'})
         nep = read_bor(fullfile(pth,'clean\thirdstage','nep_main'));
         gep = read_bor(fullfile(pth,'clean\thirdstage','eco_photosynthesis_main'));
         resp = read_bor(fullfile(pth,'clean\thirdstage','eco_respiration_main'));
        else
         nep = read_bor(fullfile(pth,'clean\thirdstage','nep_filled_with_fits'));
         gep = read_bor(fullfile(pth,'clean\thirdstage','eco_photosynthesis_filled_with_fits'));
         resp = read_bor(fullfile(pth,'clean\thirdstage','eco_respiration_filled_with_fits'));
        end
    catch %#ok<*CTCH>
        % (Zoran, Apr 3, 2018):
        %  - Set defaults to NaN so the program does not break down if one site
        %    has issues with one year.
        hhours =(datenum(cntYears,12,31)-datenum(cntYears,1,0)) * 48;
        nep = zeros(hhours,1);
        gep = zeros(hhours,1);
        resp = zeros(hhours,1);        
    end
    nepcum = cumsum(12e-6*30*60*nep(find(~isnan(nep))));
    gepcum = cumsum(12e-6*30*60*gep(find(~isnan(gep))));
    respcum = cumsum(12e-6*30*60*resp(find(~isnan(resp))));
    
    % load in nep, gep and resp from database containing traces with
    % the implementation of small gf of nep
    %pth_db = ['\\Annex001\database\' num2str(years(i)) '\' siteId '\'];
    if isempty(pth_refdb)
      %pth_db = ['D:\clean_db_backups\20100926\database\' num2str(years(i)) '\' siteId '\'];
      pth_db = ['D:\clean_db_backups\20110508\' num2str(yearsIn(cntYears)) '\' siteId '\'];
    else
      pth_db =  fullfile(pth_refdb,num2str(yearsIn(cntYears)),siteId);
    end
    try

        if ismember(siteId,{'MPB1' 'MPB2' 'MPB3'})
         nep_db = read_bor(fullfile(pth_db,'clean\thirdstage','nep_main'));
         gep_db = read_bor(fullfile(pth_db,'clean\thirdstage','eco_photosynthesis_main'));
         resp_db = read_bor(fullfile(pth_db,'clean\thirdstage','eco_respiration_main'));
        else
         nep_db = read_bor(fullfile(pth_db,'clean\thirdstage','nep_filled_with_fits'));
         gep_db = read_bor(fullfile(pth_db,'clean\thirdstage','eco_photosynthesis_filled_with_fits'));
         resp_db = read_bor(fullfile(pth_db,'clean\thirdstage','eco_respiration_filled_with_fits'));
        end
    catch %#ok<*CTCH>
        % (Zoran, Apr 3, 2018):
        %  - Set defaults to NaN so the program does not break down if one site
        %    has issues with one year.
        hhours =(datenum(cntYears,12,31)-datenum(cntYears,1,0)) * 48;

        nep_db = zeros(hhours,1);
        gep_db = zeros(hhours,1);
        resp_db = zeros(hhours,1);        
    end        
%     nep_db = read_bor(fullfile(pth_db,'clean\thirdstage','nep_filled_with_fits'));
%     gep_db = read_bor(fullfile(pth_db,'clean\thirdstage','eco_photosynthesis_filled_with_fits'));
%     resp_db = read_bor(fullfile(pth_db,'clean\thirdstage','eco_respiration_filled_with_fits'));

    nepcum_db = cumsum(12e-6*30*60*nep_db(find(~isnan(nep_db))));
    gepcum_db = cumsum(12e-6*30*60*gep_db(find(~isnan(gep_db))));
    respcum_db = cumsum(12e-6*30*60*resp_db(find(~isnan(resp_db))));
    numnans = length(find(isnan(nep)));
    numnansdb = length(find(isnan(nep_db)));
    % print outputs in rows of a table
    try
        if ~isempty(fid_log)
            fprintf(fid_log,'%10.0f%7.0f%7.0f%7.0f%8.0f%10.0f%10.0f%7.0f%6.0f%8.0f\n',yearsIn(cntYears),nepcum_db(end),gepcum_db(end),respcum_db(end),...
                                                numnansdb,nepcum(end),gepcum(end),respcum(end),numnans,nepcum_db(end)-nepcum(end));
        end
    catch
        fprintf(fid_log,'%10d ---- %s ----\n',yearsIn(cntYears),'Data missing');
    end
    try
        fprintf('%10.0f%7.0f%7.0f%7.0f%8.0f%10.0f%10.0f%7.0f%6.0f%8.0f\n',yearsIn(cntYears),nepcum_db(end),gepcum_db(end),respcum_db(end),...
                                            numnansdb,nepcum(end),gepcum(end),respcum(end),numnans,nepcum_db(end)-nepcum(end));
    catch
        fprintf('%10d ----  %s  ----\n',yearsIn(cntYears),'Data missing');
    end
                                       
end