function save_biomet_climate_to_EddyPro(siteId,year,pth_out);

% saves miscVariables Tair and Pbar used in biomet flux calculations to an
% ascii file in EddyPro format; needed to run EddyPro calculations on
% biomet data

pth = biomet_path(year,siteId,'fl');
Tair = read_bor(fullfile(pth,'MiscVariables.Tair'));
Pbar = read_bor(fullfile(pth,'MiscVariables.BarometricP'));
tv  = read_bor(fullfile(pth,'TimeVector'),8);
TS = datestr(tv,'mm-dd-yyyy HHMM');
%--------------------------------------------------
% Create the 2 header lines, SMAP preferred format
%--------------------------------------------------
header1 = 'TIMESTAMP_1,Ta_1_1_1,Pa_1_1_1';
header2 = 'mm-dd-yyyy HHMM,K,Pa';

export_mat = [ Tair+273.15 1000*Pbar];

%-------------------------------------------
% Create export filename
%-------------------------------------------
year_str = num2str(year);
file_name = [ upper(siteId) '_' year_str '_biomet_data_EddyPro.csv' ];
tic
%-------------------------------------------
% Write output file line by line
%-------------------------------------------
fp = fopen(fullfile(pth_out,file_name),'w');
if fp>0
    fprintf(fp,['%s\n'],header1);
    fprintf(fp,['%s\n'],header2);
    for k = 1:length(tv)
        % Format row
        str = format_dataline(export_mat(k,:),4);
        fprintf(fp,['%s,%s\n'],TS(k,:),str);
    end
    fclose(fp);
    disp(['Exported ' file_name ' in ' num2str(toc) 's']);
else
    disp(['Could not open ' fullfile(pth_out,file_name)]);
end