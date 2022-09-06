function[C] = cr_chamber_data(doys,years, select);
%Program to plot CR_chamber data
%
% doys = [datenum(2003,6,13):datenum(2003,6,19)];
pause_flag = 0;

if exist('years')==0 |isempty(years);
    years  = [2003];
end

if nargin < 3
    select = 0;
end

pth_ch = '\\paoa001\SITES\CR\CSI_net\old\';


%pth = biomet_path('yyyy','cr','cl');
%GMT_shift =  8/24;       %shift grenich mean time to 24hr day
%tv = read_bor([pth 'fr_clim\fr_clim_106_tv'],8,[],years);
%tv = tv-GMT_shift;

startDate = datenum(min(years),1,1);     
st        = min(doys);
ed        = max(doys);

%if max(doys) > 70000
%    indOut    = find(tv >=st & tv <= ed);
%else
%    indOut    = find(tv >=st+startDate-1 & tv <= ed+startDate-1);
%    st = st+startDate-1;
%    ed = ed+startDate-1;
%end
%t = tv(indOut)-startDate+1;

st = st - startDate + 1;
ed = ed - startDate + 1;

%-----------------------------------------------
%load in files

doys     = [st:1:ed];
C        = [];
nan_data = NaN.*ones(14400,12);

for i          = 1:length(doys);
   fileName    = ['CH_21X.' num2str(doys(i))];
   if i == 1;
      try; C   = dlmread([pth_ch fileName],','); catch; C = nan_data; end;
   else
      [m,n]    = size(C);
      try, tmp = dlmread([pth_ch fileName]); catch; tmp = nan_data; end
      C        = [C; tmp];
   end   
end


