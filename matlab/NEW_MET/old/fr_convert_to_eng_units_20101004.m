function [EngUnits,chi,test_var] = FR_convert_to_eng_units(RawData,DAQ_SYS_TYPE,Config_param,chi)
% 
% EngUnits = FR_convert_to_eng_units(RawData,DAQ_SYS_TYPE,Config_param)
%
%   This function converts RawData collected by eddy correlation system
%   programs (UBC_GillR2 and UBC_DAQbook) to engineering units without
%   all corrections. For the list of corrections that are not done see
%   Correct_EngUnits.m.
%
%   Inputs:
%       RawData         - raw data from GillR2 or DAQbook (each variable is
%                         in its own row).
%       DAQ_SYS_TYPE    - flag:
%                           1 - GillR2
%                           2 - DAQbook
%                           3 - GillR3
%       Config_param    - a structure containing all the parameters
%                         needed for the conversion (see Set_Config_Par.m)
%
%   Outputs:
%       EngUnits        - engineering units 
%       chi             - Water vapour (mmol/mol of wet air) when DAQ_SYS_TYPE = 2
%                         When DAQ_SYS_TYPE = 1 chi is virtual air temperature (cross wind corrected)
%
%
%
%
% (c) Nesic Zoran           File created:       Oct 17, 1997
%                           Last modification:  March 4, 2008
%

%
% Revisions:
%   March 4, 2008
%       -added a check for GillR3 sonic under "case 1" so that GillR3
%       digital data at CR could be handled--this function had been changed
%       at CR in 2005 (Nick)
%   May 2, 2007
%       -changed the call to fr_licor_h under case 99 so that flagX = 5
%       now no temp or pressure corrections are applied to LI-7000 water
%       voltages (Nick)
%   Feb 19, 2007
%       -added a third case to the switch statement to handle a DAQ system
%       with dummy input voltages created from LI-7000 serial data (Nick)
%   Nov 18, 1999
%       - added protection from using too big zero offsets on MUX cards (CR DAQ had a 90mV
%         offset due to slow settling time of the TC card that preceeded MUX1 measurement).
%         That would cause all the rest of the signals on MUX1 to be offset by 90mV!
%         This fix should take care of that.
%       - added proper handling of zero-offset removal for channels above 15 (MUX1 goes to
%         20 channels + MUX2 21-36)
%   Mar 24, 1999
%       - added support for CSAT3
%   May 11, 1998
%       - fixed bug that prevented program from running when RawData_DAQ had less than
%         20 channels. Changed:
%                   if n > 15
%                       EngUnits(20,:)  = ...
%         to
%                   if n > 19
%                       EngUnits(20,:)  = ...
%
%   Apr 16, 1998
%       -   fixed an error in cross wind correction for DAQbook version of Tair
%           changed:  v_n2   = 0.5 * (EngUnits(14,:) + EngUnits(13,:)).^2 +...
%           to:       v_n2   = 0.5 * (EngUnits(14,:) + EngUnits(12,:)).^2 +...
%   Apr  2, 1998
%       -   added barometric-pressure correction for the tower hight (see fr_p_bar.m)
%       -   included cross-wind correction of sos for DAQ measurements of GillR2's Tair
%   Apr  1, 1998
%       - fixed the bug when c.filters has been used instead of Config_param.filters
%   Mar 30, 1998
%       -   introduced different filters for each pressure transducer.
%   Jan  4, 1998
%       -   removed line:        [cp,hp,Tc,Th,pp]= licor(Config_param.licor);
%           from the program. All the LiCor parameters are now in ConfigParam
%           (see fr_init_all)
%
%   Jan  3, 1998
%       -   changed (for GillR2):
%               EngUnits(5,:) = RawData(5,:);                               % the rest is in milivolts anyway
%           to
%               EngUnits(5:n,:) = RawData(5:n,:);                           % the rest is in milivolts anyway
%           given the user a chance of saving *all* GillR2 analog inputs as milivolts
%
%   Dec 29, 1997
%       -   reduced filtering on Pgauge and Plicor down from 0.99 to 0.9
%   Nov 30, 1997
%       -   Removed a few comment lines
%

if ~exist('chi')
    chi = 0;                                                        % term needed for humidity correction of Tair
end                                                                 % (GillR2)

[n,m] = size(RawData);
EngUnits  = zeros(n,m);

switch DAQ_SYS_TYPE
%     case 1,
%        
%        
%         % wind speed (1:3) in m/2, Tair (4) in degC,
%         % (5) in milivolts
%         
%         EngUnits(1:3,:) = RawData(1:3,:) * 0.01;
%         u               = EngUnits(1,:);
%         v               = EngUnits(2,:);
%         w               = EngUnits(3,:);
%         v_n2            = 0.5 * (u + w).^2 + v.^2;
%         sos             = RawData(4,:) .* 0.02;
%         sos_corrected   = (sos.^2 + v_n2).^0.5;                     % cross wind correction
%         test_var        = [sos;sos_corrected];
%         Tair_v          = sos_corrected .^ 2 ./403 - 273.16;        % virtual air temp.
%         Tair_a          = (Tair_v+273.16)./ (1 + 0.32 .* chi ./ 1000) - 273.16;      % air temperature (humidity corrected)
% 
%         EngUnits(4,:)   = Tair_a;
%         chi             = sos .^ 2 ./403 - 273.16;                  % virtual air temp. w/o corrections
%         
%         EngUnits(5:n,:) = RawData(5:n,:);                           % the rest is in milivolts anyway

    case 1,
        
        if ~strcmp(upper(Config_param.sonic),'GILLR3')       
            % wind speed (1:3) in m/2, Tair (4) in degC,
            % (5) in milivolts
            
            EngUnits(1:3,:) = RawData(1:3,:) * 0.01;
            u               = EngUnits(1,:);
            v               = EngUnits(2,:);
            w               = EngUnits(3,:);
            v_n2            = 0.5 * (u + w).^2 + v.^2;
            sos             = RawData(4,:) .* 0.02;
            sos_corrected   = (sos.^2 + v_n2).^0.5;                     % cross wind correction
            test_var        = [sos;sos_corrected];
            Tair_v          = sos_corrected .^ 2 ./403 - 273.16;        % virtual air temp.
            Tair_a          = (Tair_v+273.16)./ (1 + 0.32 .* chi ./ 1000) - 273.16;      % air temperature (humidity corrected)
            
            EngUnits(4,:)   = Tair_a;
            chi             = sos .^ 2 ./403 - 273.16;                  % virtual air temp. w/o corrections
            
            EngUnits(5:n,:) = RawData(5:n,:);                           % the rest is in milivolts anyway
        else
            [Sonic_out,Tair_v,sos] = fr_GillR3_calc(Config_param.sonic_poly,RawData(1:4,:),chi);
            EngUnits = [Sonic_out; RawData(5,:)];
            test_var        = [sos;sos];
        end
        
    case 2,
        
        % assumptions:
        % Channels: 1-4 Thermocouple card (1 - cold junc. temp, 2 - zero_off, 3 - TC1, 4 - TC2)
        % Channels: 5-15 Eddy corr. (5 - zero_off, 6 - co2, 7 - h2o, 8 - Tbench, 9 - Psample,
        %                            10 - Pgauge, 11 - Pref, 12 - wind_w, 13 - Tair, 14 - wind_u,
        %                            15 - KH2O)
        
        % first convert RawData to voltage (mV)
        gains           = Config_param.gains(:);                    % extract a column of gains
        gains           = gains(:,ones(m,1));                       % make it a matrix
        count2volt      = 5000/2^15;                                % voltage conversion (5V = 2^15)
        EngUnits        = RawData ./ gains .* count2volt;           % EngUnits in (mV)
        
        % then convert the thermocouple measurements
        
        % look this up in Andy's books
        N1 = 3;
        N2 = 4;
        nn = N1:N2;
        zero_off        = EngUnits(N1-1,:);                         % get the zero offset (col #2)
        zero_off        = zero_off(ones(N2-N1+1,1),:);              % make it a matrix
        CJC             = EngUnits(N1-2,:);                         % get the cold junction temp (col #1)
        CJC             = CJC(ones(N2-N1+1,1),:);                   % make it a matrix
        
        % Removed Nov 18, 1999
        % EngUnits(nn,:)  = (EngUnits(nn,:) - zero_off)/0.0609 + CJC; % calculate TC temps. (approx. gain)
        EngUnits(nn,:)    = fr_calc_tc((EngUnits(nn,:) - zero_off)) + CJC; % calculate TC temps. (Nov 18, 1999)
        
        % now deal with the rest of the data
        N1 = 6;
        N2 = 20;                                                    % Increased from 15 to 20 Nov 18, 1999
        nn = N1:N2;
        zero_off        = EngUnits(N1-1,:);                         % get the zero offset (col #5)
        % Added Nov 18, 1999------------
        ind             = find(abs(zero_off) > 10);                 % disregard zero offset > +-10mV
        zero_off(ind)   = 0 * ind;                                  % More than 10mV is almost impossible to have
        % so it would mean that DAQ is having problems.
        % It's then better to disregard than to use the values
        % ------------------------------
        zero_off        = zero_off(ones(N2-N1+1,1),:);              % make it a matrix
        EngUnits(nn,:)  = EngUnits(nn,:) - zero_off;                % remove zero offset
        
        if n > 20 %then                                              % Added Nov 18, 1999
            N1 = 22;                                                 % do the same for the second MUX if it exists
            N2 = n;                                                 % 
            nn = N1:N2;                                             %
            zero_off        = EngUnits(N1-1,:);                     % get the zero offset (col #21)
            ind             = find(abs(zero_off) > 10);             % disregard zero offset > +-10mV
            zero_off(ind)   = 0 * ind;                              %  
            zero_off        = zero_off(ones(N2-N1+1,1),:);          % make it a matrix
            EngUnits(nn,:)  = EngUnits(nn,:) - zero_off;            % remove zero offset
        end 
        
        Tbench          = polyval(Config_param.Tbench_poly, ...
            EngUnits(8,:));                   % calculate optical bench temp.
        EngUnits(8,:)   = Tbench;
        
        Ps              = polyval(Config_param.Psample_poly, ...
            EngUnits(9,:));                   % sample cell pressure
        Ps              = filtfilt(Config_param.filters.Pl.b,Config_param.filters.Pl.a,[mean(Ps(1:20)) * ...
                ones(1,20) Ps]);
        Ps              = Ps(21:length(Ps));
        EngUnits(9,:)   = Ps;
        
        Pg              = polyval(Config_param.Pgauge_poly, ...
            EngUnits(10,:));                  % gauge pressure
        Pg              = filtfilt(Config_param.filters.Pg.b,Config_param.filters.Pg.a,[mean(Pg(1:20)) * ...
                ones(1,20) Pg]);
        Pg              = Pg(21:length(Pg));
        EngUnits(10,:)  = Pg;
        
        Pref            = polyval(Config_param.Pref_poly, ...
            EngUnits(11,:));                     % ref.cell pressure
        Pref            = filtfilt(Config_param.filters.Pr.b,Config_param.filters.Pr.a,[mean(Pref(1:20)) * ...
                ones(1,20) Pref]);
        Pref            = Pref(21:length(Pref));
        EngUnits(11,:)  = Pref;
        
        cp              = Config_param.c_poly;
        hp              = Config_param.h_poly;
        Tc              = Config_param.Tc;
        Th              = Config_param.Th;
        
        [h2o,chi]       = fr_licor_h( ...
            hp, Th, Ps, Tbench, ...
            Config_param.H2O_Cal,EngUnits(7,:));
        EngUnits(7,:)   = h2o;
        
        co2             = fr_licor_c( ...
            cp, Tc, Ps, Tbench, ...
            Config_param.CO2_Cal, ...
            EngUnits(6,:), [], chi);
        EngUnits(6,:)   = co2;
        
        switch upper(Config_param.sonic)
            case 'GILLR3',
                zz              = [14 16 12 13];
                [EngUnits(zz,:),Tair_v,sos]  = ...
                    fr_GillR3_calc(Config_param.sonic_poly,EngUnits(zz,:),chi);
                Tair_a          = EngUnits(13,:);
                
            case 'GILLR2',
                sos             = polyval(Config_param.sonic_poly(2,:),EngUnits(13,:));             % speed of sound
                EngUnits(12,:)  = polyval(Config_param.sonic_poly(1,:),EngUnits(12,:));             % wind_w
                EngUnits(14,:)  = polyval(Config_param.sonic_poly(1,:),EngUnits(14,:));             % wind_u
                if n > 15                            
                    EngUnits(16,:)  = polyval(Config_param.sonic_poly(1,:),EngUnits(16,:));         % wind_v
                    v_n2        = 0.5 * (EngUnits(14,:) + EngUnits(12,:)).^2 +...
                        EngUnits(16,:).^2;
                    sos         = (sos.^2 + v_n2).^0.5;                                                  % cross wind correction
                end
                Tair_v          = sos .^2 ./403 - 273.16;                                               % virtual temp
                Tair_a          = (Tair_v+273.16)./ (1 + 0.32 .* chi ./ 1000) - 273.16;      % air temperature (humidity corrected)
                EngUnits(13,:)  = Tair_a;                                                                   % final storage for Tair
                
            case 'CSAT',
                zz              = [14 16 12 13];
                [EngUnits(zz,:),Tair_v,sos]  = ...
                    fr_CSAT_calc(Config_param.sonic_poly,EngUnits(zz,:),chi);
                Tair_a          = EngUnits(13,:);
                
        end
        
        if n > 19
            EngUnits(20,:)  = ...
                polyval(Config_param.Pbar,EngUnits(20,:));                                   % Barometeric pressure
            EngUnits(20,:)  = filtfilt(Config_param.filters.Pb.b, ...
                Config_param.filters.Pb.a,EngUnits(20,:));
            EngUnits(20,:)  = fr_p_bar(EngUnits(20,:), ...
                Config_param.BarometerZ,Tair_a);                                % adjust the pressure for z
        end
        
        ind             = find(EngUnits(15,:) <=0 );                %
        EngUnits(15,ind)= NaN * ones(size(ind));                    % remove voltages =< 0
        EngUnits(15,:)  = polyval(Config_param.KH2O_poly, ...
            abs(log(EngUnits(15,:))));               % KH2O
        
        test_var        = [];                                       % dummy
        
    case 99,
        
        % same as case 2 except that the voltages are simply dummy
        % voltages created from LI-7000 output--therefore all voltages are
        % already corrected.
        
        % assumptions:
        % Channels: 1-4 Thermocouple card (1 - cold junc. temp, 2 - zero_off, 3 - TC1, 4 - TC2)
        % Channels: 5-15 Eddy corr. (5 - zero_off, 6 - co2, 7 - h2o, 8 - Tbench, 9 - Psample,
        %                            10 - Pgauge, 11 - Pref, 12 - wind_w, 13 - Tair, 14 - wind_u,
        %                            15 - KH2O)
        
        
        % first convert RawData to voltage (mV)
        gains           = Config_param.gains(:);                    % extract a column of gains
        gains           = gains(:,ones(m,1));                       % make it a matrix
        count2volt      = 5000/2^15;                                % voltage conversion (5V = 2^15)
        EngUnits        = RawData ./ gains .* count2volt;           % EngUnits in (mV)
        
        % then convert the thermocouple measurements
        
        % look this up in Andy's books
        N1 = 3;
        N2 = 4;
        nn = N1:N2;
        zero_off        = EngUnits(N1-1,:);                         % get the zero offset (col #2)
        zero_off        = zero_off(ones(N2-N1+1,1),:);              % make it a matrix
        CJC             = EngUnits(N1-2,:);                         % get the cold junction temp (col #1)
        CJC             = CJC(ones(N2-N1+1,1),:);                   % make it a matrix
        
        % Removed Nov 18, 1999
        % EngUnits(nn,:)  = (EngUnits(nn,:) - zero_off)/0.0609 + CJC; % calculate TC temps. (approx. gain)
        EngUnits(nn,:)    = fr_calc_tc((EngUnits(nn,:) - zero_off)) + CJC; % calculate TC temps. (Nov 18, 1999)
        
        % now deal with the rest of the data
        N1 = 6;
        N2 = 20;                                                    % Increased from 15 to 20 Nov 18, 1999
        nn = N1:N2;
        zero_off        = EngUnits(N1-1,:);                         % get the zero offset (col #5)
        % Added Nov 18, 1999------------
        ind             = find(abs(zero_off) > 10);                 % disregard zero offset > +-10mV
        zero_off(ind)   = 0 * ind;                                  % More than 10mV is almost impossible to have
        % so it would mean that DAQ is having problems.
        % It's then better to disregard than to use the values
        % ------------------------------
        zero_off        = zero_off(ones(N2-N1+1,1),:);              % make it a matrix
        EngUnits(nn,:)  = EngUnits(nn,:) - zero_off;                % remove zero offset
        
        if n > 20 %then                                              % Added Nov 18, 1999
            N1 = 22;                                                 % do the same for the second MUX if it exists
            N2 = n;                                                 % 
            nn = N1:N2;                                             %
            zero_off        = EngUnits(N1-1,:);                     % get the zero offset (col #21)
            ind             = find(abs(zero_off) > 10);             % disregard zero offset > +-10mV
            zero_off(ind)   = 0 * ind;                              %  
            zero_off        = zero_off(ones(N2-N1+1,1),:);          % make it a matrix
            EngUnits(nn,:)  = EngUnits(nn,:) - zero_off;            % remove zero offset
        end 
        
        Tbench          = polyval(Config_param.Tbench_poly, ...
            EngUnits(8,:));                   % calculate optical bench temp.
        EngUnits(8,:)   = Tbench;
        
        Ps              = polyval(Config_param.Psample_poly, ...
            EngUnits(9,:));                   % sample cell pressure
        Ps              = filtfilt(Config_param.filters.Pl.b,Config_param.filters.Pl.a,[mean(Ps(1:20)) * ...
                ones(1,20) Ps]);
        Ps              = Ps(21:length(Ps));
        EngUnits(9,:)   = Ps;
        
        Pg              = polyval(Config_param.Pgauge_poly, ...
            EngUnits(10,:));                  % gauge pressure
        Pg              = filtfilt(Config_param.filters.Pg.b,Config_param.filters.Pg.a,[mean(Pg(1:20)) * ...
                ones(1,20) Pg]);
        Pg              = Pg(21:length(Pg));
        EngUnits(10,:)  = Pg;
        
        Pref            = polyval(Config_param.Pref_poly, ...
            EngUnits(11,:));                     % ref.cell pressure
        Pref            = filtfilt(Config_param.filters.Pr.b,Config_param.filters.Pr.a,[mean(Pref(1:20)) * ...
                ones(1,20) Pref]);
        Pref            = Pref(21:length(Pref));
        EngUnits(11,:)  = Pref;
        
        cp              = Config_param.c_poly;
        hp              = Config_param.h_poly;
        Tc              = Config_param.Tc;
        Th              = Config_param.Th;
        
        [h2o,chi]       = fr_licor_h( ...
            hp, Th, Ps, Tbench, ...
            Config_param.H2O_Cal,EngUnits(7,:),[],[],[],[],5);
        EngUnits(7,:)   = h2o;
        
        disp('...pressure, temp, broadening, dilution corrections not applied');
        co2             = fr_licor_c( ...
            cp, Tc, Ps, Tbench, ...
            Config_param.CO2_Cal, ...
            EngUnits(6,:), [] , chi, 5);                % Feb19/07: use flagX = 5 so no voltage corrections occur
        EngUnits(6,:)   = co2;
        
        switch upper(Config_param.sonic)
            case 'GILLR3',
                zz              = [14 16 12 13];
                [EngUnits(zz,:),Tair_v,sos]  = ...
                    fr_GillR3_calc(Config_param.sonic_poly,EngUnits(zz,:),chi);
                Tair_a          = EngUnits(13,:);
                
            case 'GILLR2',
                sos             = polyval(Config_param.sonic_poly(2,:),EngUnits(13,:));             % speed of sound
                EngUnits(12,:)  = polyval(Config_param.sonic_poly(1,:),EngUnits(12,:));             % wind_w
                EngUnits(14,:)  = polyval(Config_param.sonic_poly(1,:),EngUnits(14,:));             % wind_u
                if n > 15                            
                    EngUnits(16,:)  = polyval(Config_param.sonic_poly(1,:),EngUnits(16,:));         % wind_v
                    v_n2        = 0.5 * (EngUnits(14,:) + EngUnits(12,:)).^2 +...
                        EngUnits(16,:).^2;
                    sos         = (sos.^2 + v_n2).^0.5;                                                  % cross wind correction
                end
                Tair_v          = sos .^2 ./403 - 273.16;                                               % virtual temp
                Tair_a          = (Tair_v+273.16)./ (1 + 0.32 .* chi ./ 1000) - 273.16;      % air temperature (humidity corrected)
                EngUnits(13,:)  = Tair_a;                                                                   % final storage for Tair
                
            case 'CSAT',
                zz              = [14 16 12 13];
                [EngUnits(zz,:),Tair_v,sos]  = ...
                    fr_CSAT_calc(Config_param.sonic_poly,EngUnits(zz,:),chi);
                Tair_a          = EngUnits(13,:);
                
        end
        
        if n > 19
            EngUnits(20,:)  = ...
                polyval(Config_param.Pbar,EngUnits(20,:));                                   % Barometeric pressure
            EngUnits(20,:)  = filtfilt(Config_param.filters.Pb.b, ...
                Config_param.filters.Pb.a,EngUnits(20,:));
            EngUnits(20,:)  = fr_p_bar(EngUnits(20,:), ...
                Config_param.BarometerZ,Tair_a);                                % adjust the pressure for z
        end
        
        ind             = find(EngUnits(15,:) <=0 );                %
        EngUnits(15,ind)= NaN * ones(size(ind));                    % remove voltages =< 0
        EngUnits(15,:)  = polyval(Config_param.KH2O_poly, ...
            abs(log(EngUnits(15,:))));               % KH2O
        
        test_var        = [];                                       % dummy
        
end
