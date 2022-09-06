function [Stav,St1,St2,St2_3m] = calc_energy_storage_biomass_cr(clean_tv, tree_1, tree_2);
%------------------------------------------------------------------------------
% Program to calculate tree heat storage using P.Blanken's method
%
%
% See programs heatstor.m and treefs.m for Fourier Series method
%
% Based on Elyn Humphreys' 'treestor.m'
%
%------------------------------------------------------------------------------
   
%Reading in tree thermocouples from tree #1
tr_s   = tree_1(:,1);
tr_mid = tree_1(:,2);
tr_cen = tree_1(:,3);                                         

%Reading in tree thermocouples from tree #2
tr_s3   = tree_2(:,1);
tr_mid3 = tree_2(:,2);
tr_cen3 = tree_2(:,3);
tr_s27  = tree_2(:,4);
tr_cen27= tree_2(:,5);

T = [tr_s tr_mid tr_cen tr_s3 tr_mid3 tr_cen3 tr_s27 tr_cen27];

%Calcultion of storage in the tree trunk
r1 =[0.164 0.124 0.064 0];          %annuli radii   m
r2 =[0.15 0.10 0.03 0];
r3 =[0.0279 0.0254 0];
p=[1148 757 757];                 %density   kgwood&water/m3tree from Cohen et al (1984)
cp=[2686 1400 1400];              %heat capacity  J/kg/degC
p3=[1148 757]; 
cp3=[2686 1400];

%Peter's aspen values
%r=[0.16 0.155 0.04 0];
%p=[1 1 1];
%cp=[2400000 2000000 1200000];
   
dT = diff(T); dT = [NaN*ones(1,8); dT];

for i=1:6
   ind = find(dT(:,i) >1 | dT(:,i) <-1);
   dT(:,i) = clean(dT(:,i), 2, ind);
end


%Calculation of dT/dt using smoothing method
%tr_s1 = [tr_s(3:length(tr_s))]';
%tr_s2 = [tr_s(1:length(tr_s)-2)]';
%dtr_s_sm = [NaN (tr_s1-tr_s2)./2 NaN]';

%tr_mid1 = [tr_mid(3:length(tr_mid))]';
%tr_mid2 = [tr_mid(1:length(tr_mid)-2)]';
%dtr_mid_sm = [NaN (tr_mid1-tr_mid2)./2 NaN]';

%tr_cen1 = [tr_cen(3:length(tr_cen))]';
%tr_cen2 = [tr_cen(1:length(tr_cen)-2)]';
%dtr_cen_sm = [NaN (tr_cen1-tr_cen2)./2 NaN]';

%dT_sm = [dtr_s_sm dtr_mid_sm dtr_cen_sm];

%Stand characteristics
Sd = 1054/10000;         %stand density
rav = 23.74./100./2;     %stand mean radius
%Ff = 0.45;              %tree form factor from P.Blanken's OA calculations
Ff = 0.49;                %tree form factor - cylinder-to-Smalain vol from CR calculations (see treevol_cr.m)
Ff2 = [0.72 3.5]; %cylinder-to-Smalain vol for bottom section and top section ... based on r for tree#2 and h2

vol_corr = (rav./r1(1)).^2;
vol_corr2 = (rav./r2(1)).^2;
%vol_corr = 1;
%vol_corr2 = 1;

h1 = 33;
h2 = [19.82 9.14]; %for a total ht of 28.96m (bottom section, top section)

%St = dt(1800s)*mean tree vol/msmt tree vol*stand density*tree form factor*height*pi*sum(annuli width *pcp*dT)
St1 = (1/1800).*vol_corr.*Sd.*Ff.*h1.*pi.*(((r1(1)^2-r1(2)^2).*p(1).*cp(1).*dT(:,1))+...
   ((r1(2)^2-r1(3)^2).*p(2).*cp(2).*dT(:,2))+((r1(3)^2-r1(4)^2).*p(3).*cp(3).*dT(:,3)));

%storage for tree#2 using only 3 m values and method above
St2_3m = (1/1800).*vol_corr2.*Sd.*Ff.*sum(h2).*pi.*(((r2(1)^2-r2(2)^2).*p(1).*cp(1).*dT(:,4))+...
   ((r2(2)^2-r2(3)^2).*p(2).*cp(2).*dT(:,5))+((r2(3)^2-r2(4)^2).*p(3).*cp(3).*dT(:,6)));

%storage for tree#2 a is at 3m and b is at 26m (divided into 2/3 bottom and 1/3 top)
St2a = (1/1800).*Sd.*Ff2(1).*h2(1).*pi.*(((r2(1)^2-r2(2)^2).*p(1).*cp(1).*dT(:,4))+...
   ((r2(2)^2-r2(3)^2).*p(2).*cp(2).*dT(:,5))+((r2(3)^2-r2(4)^2).*p(3).*cp(3).*dT(:,6)));

St2b = (1/1800).*Sd.*Ff2(2).*h2(2).*pi.*(((r3(1)^2-r3(2)^2).*p3(1).*cp3(1).*dT(:,7))+...
   ((r3(2)^2-r3(3)^2).*p3(2).*cp3(2).*dT(:,8)));

vol_corr3 = Ff.*(h1*pi*rav.^2)./((Ff2(1).*h2(1)*pi*r2(1).^2)+(Ff2(2).*h2(2)*pi*r3(1).^2));

St2 = vol_corr3.*(St2a+St2b);

%Stav = (St1./Ff2(1)+St2./Ff2(2))./2;  %equivalent to 2 stacked cylinders

%Stav = (St1+St2_3m)./2;  %mean of 2 trees
Stav = (St1+St2)./2;  %mean of 2 trees

% Calc the best available average
ind_nan = find(isnan(St2) == 1);
Stav(ind_nan) = (St1(ind_nan)+St2_3m(ind_nan))./2;

ind_nan = find(isnan(St2_3m) == 1);
Stav(ind_nan) = St1(ind_nan);


