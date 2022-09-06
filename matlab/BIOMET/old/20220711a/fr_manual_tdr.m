function [tv, tdr] = fr_manual_tdr(Year,SiteId);
% [tv, tdr] = fr_manual_tdr(Year,SiteId);
%
% Based on Elyn's manual_tdr_2002
%
% This function assumes that manual TDR readings are located at
% \\annex001\database\YYYY\Manual_TDR\*.xls 
% These exel files are required to have a fixed format !!!

pth_tdr = biomet_path(Year,SiteId,'Manual_TDR');

warning off

auto = 0;
auto_set = 0;
offset = 0;

[cell_num,cell_txt] = xlsread(fullfile(pth_tdr,[SiteId '_TDR_' num2str(Year) '_formatted.xls']));

Station = cell_txt(4:end,1);
Station = reshape(Station,2,length(Station)/2);
Station = [Station(2,:);Station(2,:)];
Station = Station(:);

tv = cell_num(1,4:end)'+datenum(1900,1,-1);

Lprobe  = cell_num(2:end,2)';

D1      = cell_num(2:end,3)';
D2      = cell_num(2:end,4:end)';

for i = 1:size(D2,1);
    dD(i,:) = (D2(i,:) - D1).*100;   %m to cm 
end

dT  = 2.*dD./30;                 %cm to nsec (have to double the distance here!?)

switch upper(SiteId)
    case 'CR';
        % Deal with this later
    case 'OY'
        LOM = [6 6 1 1 0.5 0.5 2.5 2.5 1.5 1.5 3 3 2 2 20 20 2 2 1 1];
        porosity = 0.58;
    case 'YF'
        LOM = [1 1 5 5 1 1 2 2 2 2 2 2 2 2 6 6 5 5 6 6]; %determined using 4 soilco2 collar excavations
        porosity = 0.64;
end

%----------------------------------------------------------
%calculate volumetric water content:
if SiteId ~= 'CR'
    Theta_v = tdr_msmt_conversion(dT,Lprobe,LOM,offset);
    Theta_v = Theta_v;                     %in fraction
    
    %Topp et al version:
    for i = 1:size(dD,1);
        Kb(i,:)  = (dD(i,:)./(0.99.*Lprobe)).^2;
        Theta_v2(i,:) = (Kb(i,:).^0.5 - (2 - porosity))./8; %from WinTDR manual (mixing model)
    end
end


%----------------------------------------------------------
keep    = find(tv >= datenum(Year,1,1) & tv < datenum(Year+1,1,1));
Theta_v = Theta_v(keep,:);
tv      = tv(keep);

ind20 = find(Lprobe == 20);
ind60 = find(Lprobe == 60);
ind90 = find(Lprobe >= 90);

tdr.a = Theta_v(:,ind20);
tdr.b = Theta_v(:,ind60);
tdr.c = Theta_v(:,ind90);
