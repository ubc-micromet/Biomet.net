function [smfilt] = clean_MH_eco5_data(tv,probe_num,smraw)

% cleans eco-5 soil moisture probe data from Malahat where 12 probes were used
% to measure a soil moisture profile in 2007. Probes require 2500mV
% excitation but draw 10mA (rather than the 2.5mA of the eco-20; the
% excitation voltage from the datalogger was insufficient with all 12 probes in series, so the data
% requires filtering (in this function) to get rid of a diurnal temperature
% signal in the output voltages of most of the probes.

% See calc_MH_soilmoist for a gain and offset correction

% file created: April 22, 2008          Last modified: April 22, 2008
% Revisions:

dv = datevec(tv(1000));
year = dv(1);
doy = tv-datenum(year,1,0)-8/24;
if dv(1) == 2007  
    switch probe_num
        case 19
            
            ind_prefil = find((doy>=199.6 & doy<199.7)|(doy>=202.7 & doy<202.95)|(doy>=230.4 & doy<230.65)|...
                (doy>=246.8 & doy<246.86)|(doy>=273.05 & doy<273.15)|(doy>=291.2 & doy<291.4)|...
                (doy>=337.2 & doy<337.25)|(doy>=337.76 & doy<337.83));
            
            ind_postfil = find((doy>=198.86 & doy<200.07)|(doy>=202.03 & doy<203.495)|(doy>=229.75 & doy<232.55)|...
                (doy>=272.435 & doy<273.81)|(doy>=279.98 & doy<280.95)|...
                (doy>=290.955 & doy<291.84)|(doy>=315.68 & doy<316.75)|(doy>=319.25 & doy<320.35)|(doy>=332.05 & doy<333.24)|...
                (doy>=335.92 & doy<339.94)|(doy>=337.76 & doy<337.83)|(doy>=348 & doy<361.34));
            
        case 20
            
            ind_prefil = find((doy>=199.6 & doy<199.7)|(doy>=202.7 & doy<202.95)|(doy>=230.4 & doy<230.65)|...
                (doy>=246.8 & doy<246.86)|(doy>=273.05 & doy<273.15)|(doy>=291.2 & doy<291.4)|...
                (doy>=337.2 & doy<337.25)|(doy>=337.76 & doy<337.83));
            
            ind_postfil = find((doy>=198.86 & doy<200.07)|(doy>=202.03 & doy<203.495)|(doy>=229.75 & doy<232.55)|...
                (doy>=246.035 & doy<247.8)|(doy>=272.435 & doy<273.81)|(doy>=279.98 & doy<280.95)|...
                (doy>=290.955 & doy<291.84)|(doy>=315.68 & doy<316.75)|(doy>=319.25 & doy<320.35)|(doy>=332.05 & doy<333.24)|...
                (doy>=335.92 & doy<339.94)|(doy>=337.76 & doy<337.83)|(doy>=348 & doy<361.34));
            
        case 21
            
            ind_prefil = find((doy>=335.92 & doy<339.94));
            
            ind_postfil = find((doy>=335.92 & doy<339.94)|(doy>=349 & doy<360.86));
            
        case 22
            
            ind_prefil = find((doy>=199.6 & doy<199.7)|(doy>=202.7 & doy<202.95)|(doy>=230.4 & doy<230.65)|...
                (doy>=246.8 & doy<246.86)|(doy>=273.05 & doy<273.15)|(doy>=291.2 & doy<291.4)|...
                (doy>=337.2 & doy<337.25)|(doy>=337.76 & doy<337.83));
            
            ind_postfil = find((doy>=198.86 & doy<200.07)|(doy>=202.03 & doy<203.495)|(doy>=229.75 & doy<232.55)|...
                (doy>=272.435 & doy<273.81)|(doy>=279.98 & doy<280.95)|...
                (doy>=290.955 & doy<291.84)|(doy>=315.68 & doy<316.75)|(doy>=319.25 & doy<320.35)|(doy>=332.05 & doy<333.24)|...
                (doy>=335.92 & doy<339.94)|(doy>=337.76 & doy<337.83));
            
            
        case 23
            
            ind_prefil = find((doy>=199.6 & doy<199.7)|(doy>=202.7 & doy<202.95)|(doy>=230.4 & doy<230.65)|...
                (doy>=246.8 & doy<246.86)|(doy>=273.05 & doy<273.15)|(doy>=291.2 & doy<291.4)|...
                (doy>=337.2 & doy<337.25)|(doy>=337.76 & doy<337.83));
            
            
            ind_postfil = find((doy>=198.86 & doy<200.07)|(doy>=202.03 & doy<203.495)|(doy>=231 & doy<232.55)|...
                (doy>=273.05 & doy<273.81)|(doy>=290.955 & doy<291.84)|(doy>=315.68 & doy<316.75)|...
                (doy>=319.25 & doy<320.35)|(doy>=335.92 & doy<339.94));
            
            
        case 24
            ind_prefil = find((doy>=199.6 & doy<199.7)|(doy>=202.7 & doy<202.95)|(doy>=230.4 & doy<230.65)|...
                (doy>=246.8 & doy<246.86)|(doy>=291.2 & doy<291.4)|...
                (doy>=337.2 & doy<337.25)|(doy>=337.76 & doy<337.83));
            
            ind_postfil = find((doy>=198.86 & doy<200.07)|(doy>=202.03 & doy<203.495)|(doy>=229.75 & doy<232.55)|...
                (doy>=278.9 & doy<281.5)|(doy>=290.65 & doy<291.84)|(doy>=294.2 & doy<296.7)|(doy>=315.68 & doy<316.75)|...
                (doy>=319.25 & doy<320.35)|(doy>=332.05 & doy<333.24)|...
                (doy>=335.92 & doy<339.94)|(doy>=337.76 & doy<337.83)|(doy>=348 & doy<361.34));
            
        case 25
            
            ind_prefil = find((doy>=199.6 & doy<199.7)|(doy>=202.7 & doy<202.95)|(doy>=230.4 & doy<230.65)|...
                (doy>=246.8 & doy<246.86)|(doy>=273.05 & doy<273.15)|(doy>=291.2 & doy<291.4)|...
                (doy>=337.2 & doy<337.25)|(doy>=337.76 & doy<337.83));
            
            ind_postfil = find((doy>=198.86 & doy<200.07)|(doy>=202.42 & doy<203.27)|(doy>=229.75 & doy<231.01)|...
                (doy>=246.14 & doy<247.23)|(doy>=272.435 & doy<273.81)|(doy>=290.985 & doy<291.746)|...
                (doy>=335.92 & doy<339.94)|(doy>=337.76 & doy<337.83));
            
            
        case 26
            
            ind_prefil = find((doy>=199.6 & doy<199.7)|(doy>=202.7 & doy<202.95)|(doy>=230.4 & doy<230.65)|...
                (doy>=273.05 & doy<273.15)|(doy>=291.2 & doy<291.4)|...
                (doy>=337.2 & doy<337.25)|(doy>=337.76 & doy<337.83));
            
            ind_postfil = find((doy>=198.86 & doy<200.07)|(doy>=201.875 & doy<203.725)|(doy>=229.75 & doy<231.82)|...
                (doy>=272.435 & doy<273.81)|(doy>=290.985 & doy<291.746)|...
                (doy>=335.92 & doy<339.94)|(doy>=337.76 & doy<337.83));
            
            
        case 27
            
            ind_prefil = find((doy>=230.4 & doy<230.65)|...
                (doy>=273.05 & doy<273.15)|(doy>=291.2 & doy<291.4)|...
                (doy>=337.2 & doy<337.25)|(doy>=337.76 & doy<337.83));
            
            ind_postfil = find((doy>=229.75 & doy<231.82)|...
                (doy>=272.435 & doy<273.81)|(doy>=280.06 & doy<280.82)|(doy>=290.72 & doy<292.014)|...
                (doy>=337.76 & doy<337.83));
            
            
        case 28
            ind_prefil = find((doy>=199.6 & doy<199.7)|(doy>=202.7 & doy<202.95)|(doy>=230.4 & doy<230.65)|...
                (doy>=246.8 & doy<246.86)|(doy>=273.05 & doy<273.15)|(doy>=291.2 & doy<291.4)|...
                (doy>=337.2 & doy<337.25)|(doy>=337.76 & doy<337.83));
            
            ind_postfil = find((doy>=198.86 & doy<200.07)|(doy>=202.42 & doy<203.27)|(doy>=229.75 & doy<231.01)|...
                (doy>=246.14 & doy<247.23)|(doy>=272.435 & doy<273.81)|(doy>=290.985 & doy<291.746)|...
                (doy>=335.92 & doy<339.94)|(doy>=337.76 & doy<337.83));
            
        case 29
            ind_prefil = find((doy>=337.2 & doy<337.25));
            
            ind_postfil = find((doy>=335.92 & doy<366));
            
        case 30
            ind_prefil = find((doy>=337.2 & doy<337.25));
            
            ind_postfil = find((doy>=315.6 & doy<318.85)| (doy>=335.92 & doy<342) | (doy>=349.05 & doy<351.68));
            
    end
end

smfilt = NaN.*ones(length(doy),1);
ind_notnan = find(~isnan(smraw));
ind_filt = setxor(1:17520,ind_prefil);
smraw_new = filtfilt(fir1(100,0.03),1,smraw(intersect(ind_notnan,ind_filt)));
smfilt(intersect(ind_filt,ind_notnan)) = smraw_new;

% now add back abrupt changes in moisture from the original trace not captured by the
% filter
smfilt(ind_postfil)=smraw(ind_postfil);


        
        
        