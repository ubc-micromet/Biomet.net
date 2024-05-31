function create_annual_nep_report(yearsIn,pth_localdb,pth_refdb,fid_log,sitesIn)
% Create an annual nep difference report by comparing current vs ref databsase
%
%
% Zoran Nesic           File created:       May 25, 2024
%                       Last modification:  May 25, 2024

%
% Revisions:
% 

if isempty(fid_log)
    inputlogf = 0;
    fid_log = fopen('biomet_annual_nep_report.txt','wt');
else 
    inputlogf = 1;
end

fprintf(' ==================================================================================\n');
fprintf('| NEP, GEP, R from reference db; NEP_new, GEP_new, R_new from local db\n');
fprintf('| **** all values in g C m^-2 y^-1, non-ebc corrected, non-NaN totals ****\n');
fprintf('| Reference db path is %s\n',pth_refdb);
fprintf('| Local db path is %s\n',pth_localdb);

fprintf(fid_log,'%s\n',' ==================================================================================');
fprintf(fid_log,'%s\n','| NEP, GEP, R from reference db; NEP_new, GEP_new, R_new from local db');
fprintf(fid_log,'%s\n','| **** all values in g C m^-2 y^-1, non-ebc corrected, non-NaN totals ****');
fprintf(fid_log,'| Reference db path is %s\n',pth_refdb);
fprintf(fid_log,'| Local db path is %s\n',pth_localdb);

for cntSites = 1:length(sitesIn)
    try
        siteID = char(sitesIn(cntSites));
        fprintf('==================================================================================\n');
        fprintf(fid_log,'%s\n','==================================================================================');
        print_nep_table(yearsIn,siteID,pth_localdb,pth_refdb,fid_log);
    catch ME
        disp(ME.message);
    end
end

fprintf('==================================================================================\n');
fprintf(fid_log,'%s\n','==================================================================================');

if ~inputlogf
    fclose(fid_log);
end