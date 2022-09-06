function [sm_out] = calc_MH_soilmoist(clean_tv,sm_raw,eco_type,use_gaincor,probe_num);

% outputs volumteric soil water content for ECO soil moisture probes
% at the Malahat site. Decagon ECO probes: ECO-5 and ECO-20

% created by: Nick              Last modified: April 15, 2008

% revisions:

arg_default('use_gaincor',1);

dv = datevec(clean_tv(100));
year = dv(1);

% calibrations and gains
switch year
    case 2005
        eco20_m = 11e-4;
        eco20_b = -0.37;
        gain_eco20 = ones(length(clean_tv),1);
    case 2006
        eco20_m = 11e-4;
        eco20_b = -0.37;
        gain_eco20 = ones(length(clean_tv),1);
    case 2007  % soil moisture profile of Eco-5s added in June, 2007
        eco20_m = 11e-4;
        eco20_b = -0.37;
        gain_eco20 = ones(length(clean_tv),1);
        ind_a=find(clean_tv>datenum(2007,1,224) & clean_tv<datenum(2007,1,313.6));
        ind_b=find(clean_tv>datenum(2007,1,313.6) & clean_tv<datenum(2007,1,366));
        gain_eco20(ind_a)=0.96;
        gain_eco20(ind_b)=0.88;
        if probe_num == 3
            sm_raw = sm_raw+125;
            ind = find(clean_tv>=datenum(2007,1,151.6)&clean_tv<datenum(2007,1,366));
            sm_raw(ind)=sm_raw(ind)+75;
        end
        eco5_m = 11.9e-4;
        eco5_b = -0.401;
        gain_eco5 = 7.5e-4.*sm_raw+0.52; 
end

% calculate vwc using gain-corrected mV and appropriate calibration
% constants
if eco_type == 20;
    
    if use_gaincor
        sm_raw = sm_raw./gain_eco20;
    end
    sm_out = eco20_m.*sm_raw + eco20_b;
elseif eco_type == 5
    if use_gaincor
        sm_raw = sm_raw./gain_eco5;
    end
    sm_out = eco5_m.*sm_raw + eco5_b;
end