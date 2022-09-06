function create_biomet_annual_nep_report(year,pth_localdb,pth_refdb,fid_log);
%
%
% Revisions:
%
% Nov 15, 2019 (Zoran)
%   - locked the last years for OBS and OA to 2017 (last good data set).
%     There was some data for OBS in 2018 but ...
% Apr 3, 2018 (Zoran)
%   - added LGR1
%   - added a bunch of try-catch statements to stop the program failures
%     when one site is bad
%
% Feb 2, 2017 (Zoran)
%   - Fixed the last year for MPB2 (2013) and MPB3 to 2012
%

if isempty(fid_log)
    inputlogf = 0;
    fid_log = fopen('biomet_annual_nep_report.txt','wt');
else 
    inputlogf = 1;
end

disp(sprintf(' =================================================================================='));
disp(sprintf('| NEP, GEP, R from reference db; NEP_new, GEP_new, R_new from local db'));
disp(sprintf('| **** all values in g C m^-2 y^-1, non-ebc corrected, non-NaN totals ****'));
disp(sprintf('| Reference db path is %s',pth_refdb));
disp(sprintf('| Local db path is %s',pth_localdb));

fprintf(fid_log,'%s\n',' ==================================================================================');
fprintf(fid_log,'%s\n','| NEP, GEP, R from reference db; NEP_new, GEP_new, R_new from local db');
fprintf(fid_log,'%s\n','| **** all values in g C m^-2 y^-1, non-ebc corrected, non-NaN totals ****');
fprintf(fid_log,'| Reference db path is %s\n',pth_refdb);
fprintf(fid_log,'| Local db path is %s\n',pth_localdb);

try
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(2017:-1:1999,'BS',pth_localdb,pth_refdb,fid_log);
catch
end
try
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(2017:-1:2000,'PA',pth_localdb,pth_refdb,fid_log);
catch
end
try    
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(2007:-1:2003,'HJP02',pth_localdb,pth_refdb,fid_log);
catch
end
try    
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(2011:-1:1999,'CR',pth_localdb,pth_refdb,fid_log);
catch
end
try
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(year:-1:2001,'YF',pth_localdb,pth_refdb,fid_log);
catch
end
try
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(2011:-1:2000,'OY',pth_localdb,pth_refdb,fid_log);
catch
end
try
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(year:-1:2007,'MPB1',pth_localdb,pth_refdb,fid_log);
catch
end
try
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(2013:-1:2007,'MPB2',pth_localdb,pth_refdb,fid_log);
catch
end
try
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(2012:-1:2010,'MPB3',pth_localdb,pth_refdb,fid_log);
catch
end
try
    disp(sprintf('=================================================================================='));
    fprintf(fid_log,'%s\n','==================================================================================');
    print_nep_table(year:-1:2017,'LGR1',pth_localdb,pth_refdb,fid_log);
catch
end
disp(sprintf('=================================================================================='));
fprintf(fid_log,'%s\n','==================================================================================');

if ~inputlogf
    fclose(fid_log);
end