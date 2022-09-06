function [sumtabl,lst_fn] = show_licor_test(licor_num,pth_HF);

%pth_HF = 'D:\met-data\data\Li_7000_digboardtest\';
lst = dir(fullfile(pth_HF,['*.DTEST' num2str(licor_num)]));
lst_fn = {lst.name};
sumtabl = NaN*ones(length(lst),13);
for i=length(lst):-1:1
    [licor,Header] = fr_read_Digital2_file(fullfile(pth_HF,lst(i).name));
    numpts = length(licor);
    co2 = licor(:,1);
    h2o = licor(:,2);
    Tb  = licor(:,3);
    Pb = licor(:,4);
    sumtabl(i,1:13) = [ numpts mean(co2) max(co2) min(co2) mean(h2o) max(h2o) min(h2o)...
               mean(Tb) max(Tb) min(Tb) mean(Pb) max(Pb) min(Pb)];
       disp(['Read ' lst(i).name]);
end
disp(sprintf('%s','Filename       Numpts CO2_avg CO2_max CO2_min H2O_avg H2O_max H2O_min Tb_avg max min Pb_avg  Pb_max Pb_min')); 
for i=1:length(lst_fn)
    disp(sprintf('%15s %5.0f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %7.1f %7.1f %7.1f',...
        lst_fn{i},sumtabl(i,1),sumtabl(i,2),sumtabl(i,3),sumtabl(i,4),sumtabl(i,5),...
        sumtabl(i,6),sumtabl(i,7),sumtabl(i,8),sumtabl(i,9),sumtabl(i,10),...
        sumtabl(i,11),sumtabl(i,12),sumtabl(i,13))); 
end
          
%     disp(sprintf('Tb_avg: %d Tb_max: %d  Tb_min: %d',mean(Tb),max(Tb),min(Tb))); 
%     disp(sprintf('Pb_avg: %d Pb_max: %d  Pb_min: %d',mean(Pb),max(Pb),min(Pb))); pause;