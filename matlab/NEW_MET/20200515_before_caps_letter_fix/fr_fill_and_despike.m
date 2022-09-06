

function [y,x]=fr_fill_and_despike(x,GapMax);

%The fr_despike.m is not very good in catching the leading or lagging spikes (first or
%   last point). The difference calculation creates more NaNs where NaNs
%   are present in the intial trace. NaNs are already associated with times
%   of instrument failure and poor mixing (after ustar filter) but are
%   missed due to this flaw in the despiking technique. fr_fill_and_despike.m adopts a technique using
%   half hourly ensemble averaging to fill the raw trace before despiking
%   and then remove the filled points after, thus maximising the number of
%   spikes caught. During periods when spikes are more prevelant the Median Average Deviation 
%   (the basis of the despiking technique, Papale et al., 2008) will be large and a 
%   limited number of values may be accepted which the user may still feel are spikes.

    z = x;
%create periods equal to those used in despike code
    ndays       = 13;
    nhhrsday    = 48;
    window_len  = ndays*nhhrsday;
    N           = length(z);
    nPeriods	= floor(N/(window_len)); 
    x_gf_ens_an = NaN*ones(nPeriods,window_len);%creates matrice of NaNs to be filled with each periods value of gap-filled x with it's hhrly ensemble average
    NaN_an      = NaN*ones(nPeriods,window_len);%creates matrice of NaNs to be filled with each periods 1==NaN value. (see lines 62 66 and 74)
    xtra        = z(window_len*nPeriods+1:end,1);%adds in data from period not captured by nPeriods (48 points and 98 for a leap year)

%step through each period     
for i = 1:nPeriods
    
    kk = (i-1)*window_len;
    jj = kk+1:kk+window_len;%if period = 28 (17520/(13*48) for 17520 data points (half hours in a year) then this should have dimension 1:624
    
    [xr] = reshape(z(jj),nhhrsday,ndays); %reshape data to daily dimension
    
     xr = xr';
    
    hhrlym = nanmean(xr);%calculate the hhrly mean value 
     
    xrff= NaN*ones(size(xr));
    NaN_out= zeros(size(xr));
    
    %step through days in one period and find then fill nan values
    for j = 1:ndays
        
        NaN_V= zeros(size(xr(j,:)));
        
        nanind = find(isnan(xr(j,:)));
        
        NaN_V(nanind)=1;
        
        xrf = xr(j,:);
 
        xrf(nanind)=hhrlym(nanind);
        
        xrff(j,:)=xrf;
        
        NaN_out(j,:)=NaN_V;
    end
        
        
    [x_gf_ens]=reshape(xrff',1,window_len);%unfold period matrix
    [NaN_out_vec]=reshape(NaN_out',1,window_len);
    
    
    x_gf_ens_an(i,:) = x_gf_ens;%fill period matrix with x gap-filled with ensemble average
    NaN_an(i,:)      = NaN_out_vec;
    
    
end

z = reshape(x_gf_ens_an',1,nPeriods*window_len);%unfold annual matrix
NaN_final = reshape(NaN_an',1,nPeriods*window_len);

NaN_final = find(NaN_final==1);

z				= FCRN_FillSmallGapsByLinInterp(z',GapMax);%Fill any remaining NaNs. 
%This is used in particular for NEP data at UBC biomet which has a
%daily calibration hhr missing.

[y]= fr_despike(z,window_len,4);%run despiking

y(NaN_final)=NaN;%remove all ensemble gap-filled data so left with original trace minus spikes.

y = [y;xtra];%add on the extra data that is cut from the end of a trace during the ensemble averaging

