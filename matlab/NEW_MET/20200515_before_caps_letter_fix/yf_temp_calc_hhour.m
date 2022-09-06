function [Stats,IRGA,IRGA_h,GillR3]= yf_temp_calc_hhour(dateIn)

pth = 'd:\met-data\data\';
fileName = FR_DateToFileName(dateIn);
if exist(fullfile(pth,[fileName '.dy3']))~= 2
    pth = [pth fileName(1:6) '\'];
    if exist(fullfile(pth,[fileName '.dy3']))~= 2
        disp(['File: ' fullfile(pth,[fileName '.dy3']) ' does not exist!'])
        Stats = NaN;
        IRGA = NaN;
        IRGA_h = NaN;
        GillR3 = NaN;
        return
    end
end

fileName1= fullfile(pth,[fileName '.dy3']);
fileName2= fullfile(pth,[fileName '.dy4']);

[IRGA, IRGA_h] = fr_read_RS232data(fileName2);
GillR3 = FR_read_raw_data(fileName1,5,50000)'/100;
GillR3(:,4) = GillR3(:,4) - 273.15;

[IRGA, GillR3,numOfSamples,del_1,del_2]= ...
    fr_align(IRGA, GillR3,[3 4],1000,[-60 60]);

Pb = mean(IRGA(:,5));

[Cmix, Hmix, C, H] = fr_convert_open_path_irga(IRGA(:,1), IRGA(:,2), GillR3(:,4) + 273.15, Pb);  

Eddy_HF_data = [GillR3(:,1:4) Cmix Hmix];
Stats   = fr_calc_eddy(Eddy_HF_data, zeros(1,size(Eddy_HF_data,2)),'N',Pb);    
