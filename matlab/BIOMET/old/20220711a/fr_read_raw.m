function Eddy_HF_data = fr_read_raw(dateIn,SiteId)
% FR_READ_RAW Read high frequency data from any of the UBC sites
%
%   For this to work the high frequency data for the site has to
%   be made available using FR_SET_SITE.
%
%   EDDY_HF_DATA = FR_READ_RAW(DATEIN) read the high frequency data
%   for DATEIN and FR_CURRENT_SITEID and converts it to engineering units
%
%   EDDY_HF_DATA = FR_READ_RAW(DATEIN,SITEID) read the high frequency data
%   for DATEIN and SITEID and converts it to engineering units

% kai* - last modified Apr 27, 2004
%
% Revisions:
% Nov 9, 2011, Nick: OBS and PA modified to reflect new eddy systems
%                    installed in 2011.
% Jan 27, 2004, kai*: Added help comments
% Apr 27, 2004, kai*: removed obsolete path changes since new_eddy is not path of 
%                     the Biomet setup

if ~exist('SiteId')
   SiteId = FR_current_SiteId;
end

Eddy_HF_data = [];

switch upper(SiteId)
case 'CR'
   [EngUnits, RawData, DelTimes, FileName_p, EngUnits_DAQ, EngUnits_GillR2] = ...
      fr_read_and_convert(dateIn, SiteId);
   
   u = EngUnits(:,1);
   v = EngUnits(:,2);
   w = EngUnits(:,3);
   T = EngUnits(:,4);
   C = EngUnits(:,11);
   H = EngUnits(:,12);
   Tc1 = EngUnits(:,8);
   Tc2 = EngUnits(:,9);
   shift = 8;
   
   HF_Data.System(1).EngUnits     = [u v w T C H Tc1 Tc2];
   c.System(1).ChanNames    = {'u' 'v' 'w' 'T' 'C' 'H' 'Tc1' 'Tc2'};
   c.System(1).ChanUnits    = {'m/s','m/s','m/s','decC','ppm','mmol/mol','degC','degC',};
   c.System(1).FieldName = 'Eddy';
   c.System(1).Fs = 20.83;
   ind_eddy = 1;
   
case {'JP'}
   [EngUnits, RawData, DelTimes, FileName_p, EngUnits_DAQ, EngUnits_GillR2] = ...
      fr_read_and_convert(dateIn, SiteId);
   
   u = EngUnits(:,14);
   v = EngUnits(:,16);
   w = EngUnits(:,12);
   T = EngUnits(:,13);
   C = EngUnits(:,6);
   H = EngUnits(:,7);
   Tc1 = EngUnits(:,3);
   Tc2 = EngUnits(:,4);
   
   HF_Data.System(1).EngUnits     = [u v w T C H Tc1 Tc2];
   c.System(1).ChanNames    = {'u' 'v' 'w' 'T' 'C' 'H' 'Tc1' 'Tc2'};
   c.System(1).ChanUnits    = {'m/s','m/s','m/s','decC','ppm','mmol/mol','degC','degC',};
   c.System(1).FieldName = 'Eddy';
   c.System(1).Fs = 20.83;
   ind_eddy = 1;
case {'BS'}
    if dateIn < datenum(2011,3,17,12,0,0);
        [EngUnits, RawData, DelTimes, FileName_p, EngUnits_DAQ, EngUnits_GillR2] = ...
            fr_read_and_convert(dateIn, SiteId);

        u = EngUnits(:,14);
        v = EngUnits(:,16);
        w = EngUnits(:,12);
        T = EngUnits(:,13);
        C = EngUnits(:,6);
        H = EngUnits(:,7);
        Tc1 = EngUnits(:,3);
        Tc2 = EngUnits(:,4);

        HF_Data.System(1).EngUnits     = [u v w T C H Tc1 Tc2];
        c.System(1).ChanNames    = {'u' 'v' 'w' 'T' 'C' 'H' 'Tc1' 'Tc2'};
        c.System(1).ChanUnits    = {'m/s','m/s','m/s','decC','ppm','mmol/mol','degC','degC',};
        c.System(1).FieldName = 'Eddy';
        c.System(1).Fs = 20.83;
        ind_eddy = 1;
    else
        try
            [Stats_New,HF_Data] = yf_calc_module_main(dateIn,SiteId,1);
            c = fr_get_init(SiteId,dateIn);
            % Extract MainEddy
            ind_eddy = find(strcmp(upper({c.System(:).Type}),'EDDY'));
            for i = ind_eddy
                c = fr_init_complete_system(c,i);
            end
        catch
        end
    end

case {'PA'}
    if dateIn <= datenum(2010,12,31,24,0,0);
        [EngUnits, RawData, DelTimes, FileName_p, EngUnits_DAQ, EngUnits_GillR2] = ...
            fr_read_and_convert(dateIn, SiteId);

        u = EngUnits(:,14);
        v = EngUnits(:,16);
        w = EngUnits(:,12);
        T = EngUnits(:,13);
        C = EngUnits(:,6);
        H = EngUnits(:,7);
        Tc1 = EngUnits(:,3);
        Tc2 = EngUnits(:,4);

        HF_Data.System(1).EngUnits     = [u v w T C H Tc1 Tc2];
        c.System(1).ChanNames    = {'u' 'v' 'w' 'T' 'C' 'H' 'Tc1' 'Tc2'};
        c.System(1).ChanUnits    = {'m/s','m/s','m/s','decC','ppm','mmol/mol','degC','degC',};
        c.System(1).FieldName = 'Eddy';
        c.System(1).Fs = 20.83;
        ind_eddy = 1;
    else
        try
            [Stats_New,HF_Data] = yf_calc_module_main(dateIn,SiteId,1);
            c = fr_get_init(SiteId,dateIn);
            % Extract MainEddy
            ind_eddy = find(strcmp(upper({c.System(:).Type}),'EDDY'));
            for i = ind_eddy
                c = fr_init_complete_system(c,i);
            end
        catch
        end
    end
    
otherwise
   try
      [Stats_New,HF_Data] = yf_calc_module_main(dateIn,SiteId,1);
      c = fr_get_init(SiteId,dateIn);
      % Extract MainEddy
      ind_eddy = find(strcmp(upper({c.System(:).Type}),'EDDY'));
      for i = ind_eddy
          c = fr_init_complete_system(c,i);
      end
   catch
   end
   
end

no_chan = 0;
for k = ind_eddy
   
   Eddy_HF_sys(k).title = [];
   Eddy_HF_sys(k).name  = [];
   Eddy_HF_sys(k).unit  = [];
   try
       Eddy_HF_sys(k).data  = HF_Data.System(k).EngUnits;
       Eddy_HF_sys(k).tv    = [1:length(Eddy_HF_sys(k).data)]./c.System(k).Fs;
   end
   
   Eddy_HF_sys(k).name  = [c.System(k).ChanNames];
   Eddy_HF_sys(k).title = [c.System(k).ChanNames];
   Eddy_HF_sys(k).unit  = [c.System(k).ChanUnits];
   
   [n,m] = size(Eddy_HF_sys(k).data);
   
   for i = 1:m
      Eddy_HF_sys(k).name(i) = {[char(Eddy_HF_sys(k).name(i)) '_' c.System(k).FieldName]};
   end
   
   for i = 1:m
      Eddy_HF_data(no_chan+i).title    = Eddy_HF_sys(k).title(i);
      Eddy_HF_data(no_chan+i).string1  = Eddy_HF_sys(k).name(i);
      Eddy_HF_data(no_chan+i).unit     = Eddy_HF_sys(k).unit(i);
      Eddy_HF_data(no_chan+i).data     = Eddy_HF_sys(k).data(:,i);
      Eddy_HF_data(no_chan+i).tv       = Eddy_HF_sys(k).tv;
      Eddy_HF_data(no_chan+i).currentDate = dateIn;
      Eddy_HF_data(no_chan+i).System   = c.System(k).FieldName;
      Eddy_HF_data(no_chan+i).Fs       = c.System(k).Fs;
   end
   no_chan = length(Eddy_HF_data);
end

return