function h = sonic_comp_2

kais_plotting_setup

close all;

tv =[];
% tv = [tv datenum(2004,6,24)+[74/96:1/48:98/96]];
% tv = tv([1:13 17:end]);
% tv = [tv datenum(2004,6,25)+[64/96:1/48:96/96]];
% tv = [tv datenum(2004,6,26)+[2/96:1/48:10/96]];
% tv = [tv datenum(2004,6,26)+[70/96:1/48:96/96]];
% tv = [tv datenum(2004,6,27)+[2/96:1/48:16/96]];
tv = [tv datenum(2004,6,27)+[69/96:1/48:88/96]];
pth = 'D:\met-data\data';

for i = 1:length(tv)
     disp(['Processing ' datestr(tv(i))]);

    filename = fr_datetofilename(tv(i));

    % XSITE Sonic
    sonic_XSITE = FR_read_raw_data(fullfile(pth,[filename '.dx5']),5)';
    sonic_XSITE = sonic_XSITE./100;
    sonic_XSITE(:,4) = sonic_XSITE(:,4)-273.15;
    theta_XSITE = attack_angle(sonic_XSITE);
    
    % Gill SN 244 Sonic
    sonic_244 = FR_read_raw_data(fullfile(pth,[filename '.dx15']),5)';
    sonic_244 = sonic_244./100;
    sonic_244(:,4) = sonic_244(:,4)-273.15;
    theta_244 = attack_angle(sonic_244);

    % CSAT Sonic
    sonic_csat = fr_read_digital2_file(fullfile(pth,[filename '.dh7']));
    theta_csat = attack_angle(sonic_csat);
    
    figure
    plot(theta_XSITE)

end


figure
plot([sonic_XSITE_len;sonic_244_len;sonic_295_len;sonic_csat_len]')
return

function theta = attack_angle(sonic)

u = sonic(:,1);
v = sonic(:,2);
w = sonic(:,3);
U = sqrt(u.^2 + v.^2);
UU = sqrt(u.^2 + v.^2 + w.^2);

theta = 180./pi .* atan2(w,UU);

 return
