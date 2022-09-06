function [RW_ec,RW,GEPW,neeW,neeW_ec_dn] = calc_bill(clean_tv,stleafR,edleafR,nee,ST2CMF,Qa,S,...
   Ustar,R_coefW,P_coefW)
% Caculate Bill's NEE values for submission to Alan Barr and for Comparison to my methods.
%
% Based on Bill's NEEC_cal for PA
%
%	Qa			- PPFD directly from data
%	S			- Solar radiation
%
% (C) kai*									File created:  Nov. 30, 2000
%												Last modified: Nov. 30, 2000

ustarc   = 0.35; %critical value for high wind method

% --- get time series ---
[CST,year] = convert_tv(clean_tv,'doy',6);

%=== high wind method ===
RW = R_coefW(1)./(1+exp(R_coefW(2)*(R_coefW(3)-ST2CMF)));

% --- calculate photosynthesis according to model ---
PW = P_coefW(1).*Qa.*P_coefW(2)./(P_coefW(1).*Qa+P_coefW(2));

% --- fill missing nee by linear interpolation during just leafout or leaffall ---

ind = find(CST > 145 & CST < 151);
nee(ind) = interp_nan(clean_tv(ind),nee(ind));

S        = interp_nan(clean_tv,S);

% --- fill missing nee by using model ---

%High Wind Method
%==============
neeW 		= nee;

ind 			= find(S <= 0 & (isnan(neeW) | Ustar < ustarc)); % for night data
neeW(ind) = RW(ind);
ind 			= find((CST <= stleafR | CST >= edleafR) ...
   					& (isnan(neeW) | Ustar < ustarc)); % for without leave
neeW(ind) = RW(ind);
ind 			= find(S>0 & isnan(neeW) & CST > stleafR & CST < edleafR); % for daytime data with leave
neeW(ind) = RW(ind) - PW(ind);
%neeW(6880:6884) = (neeW(6879)+neeW(6885))/2;
neeW = interp_nan(clean_tv,neeW); %delete later (just temporately use)

% --- respiration ---

%High Wind Method
%==============
RWR = NaN*ones(length(CST),1);
ind 			= find(S <= 0 & Ustar >= ustarc); %nighttime data at high wind
RWR(ind) 	= nee(ind);
ind 			= find(S <= 0 & Ustar < ustarc); %nighttime data at low wind
RWR(ind) 	= RW(ind);
ind 			= find((CST < stleafR | CST > edleafR) & Ustar >= ustarc); %leafless period at high wind
RWR(ind) 	= nee(ind);
ind 			= find((CST < stleafR | CST > edleafR) & Ustar < ustarc); %leafless period at low wind
RWR(ind) 	= RW(ind);
ind 			= find(S > 0 & CST >= stleafR & CST <= edleafR); %daytime in leaf period
RWR(ind)  = RW(ind);
ind 			= find(isnan(RWR));
RWR(ind)	= RW(ind);

% --- daytime energy balance correction ---
neeW_ec_d = neeW;

Ustar = interp_nan(clean_tv,Ustar);


ind = find(S > 0 & ~isnan(Ustar));

a1 = 0.1523; a2 = 0.9579;
rf = a1.*log(Ustar) + a2;

neeW_ec_d(ind) = neeW(ind)./rf(ind);%corrected according to energy inbalance factor

ind = find(S > 0 & isnan(Ustar));

neeW_ec_d(ind) = neeW(ind)/0.87;%correct 10%

% --- nighttime energy balance correction ---

neeW_ec_dn = neeW_ec_d;

ind = find(S <= 0);

neeW_ec_dn(ind) = neeW_ec_dn(ind)/0.90;
 
RW_ec = RWR/0.881;


% --- save data ---
RW = RWR;

GEPW = RW - neeW;
