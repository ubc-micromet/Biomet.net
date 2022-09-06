function [spikes,data] = fr_calc_spikes(data,c)
% fr_calc_spikes.m Program which tallies number of spikes for all data
%
% Output:
%    spikes = no. of spikes within each data trace
%    data   = output matrix of despiked data (if selected)
% Inut:
%    data = input matrix
%    c    = a config structure that must have at least on
%       enty config_in.Spikes.Fs. Other entries in config.Spikes will be assigned the
%       following defaults if they are not found:
% 
% bp_vect = [1250:1250:floor(1800 * configIN.Spikes.Fs)]  % vector of intervals for averaging  needs to be evenly spaced
% spike_av = 'c' % 'l' for linear interp (not statistically correct), 'c' for block avg
% spike_limit = 5 % std limit for a spike to be selected
% spike_thold = spike_thold_default(1:N)) % diff limit for a spike to be selected
% where spike_thold_default = [0.25 0.25 0.25 0.2 3.65 0.5 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2]; 
% despike.ON = 1 % Remove detected spikes from data

%    E.Humphreys  23.03.01
%    Revisions:   Jun 20, 2001 - config_info change
%    Oct - Kai added removal of spikes to data output in this function
%    Oct 12, 2002 - Elyn added ini file requirement to output despiked data (if c.Spikes.despike.ON does
%           not exist, output variable data is the despiked data)            
%    Oct 18, 2004 - kai* added default configuration parameter values

%fig = 0;

N = size(data);
N = min(N);

spike_thold_default = [0.25 0.25 0.25 0.2 3.65 0.5 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2];

c = config_default(c,'bp_vect',[1250:1250:floor(1800 * c.Spikes.Fs)]);
c = config_default(c,'spike_av','c');
c = config_default(c,'spike_limit',5);
c = config_default(c,'spike_thold',spike_thold_default(1:N)); % 
c = config_default(c,'despike.ON',1);

t = [1:1:length(data(:,1))];
data_out = data;

for i = 1:N;
   [spike_inds] = fr_pick_spikes(data(:,i),c.Spikes.spike_av,...
      c.Spikes.bp_vect,c.Spikes.spike_limit,c.Spikes.spike_thold(i));
   spikes(i)    = length(spike_inds);
   
   %   try,
   %      fig = fig+1;figure(fig);clf;
   %      plot(t,data(:,i),t(spike_inds),data(spike_inds,i),'o')
   %   end
   if ~isempty(spike_inds)
      ind = find(spike_inds > 1 & spike_inds < length(data));
      data_out(spike_inds(ind),i) = (data(spike_inds(ind)-1,i) + data(spike_inds(ind)+1,i))./2;
      if spike_inds(1) == 1 
         data_out(1,i) = data(2,i);
      end
      if spike_inds(end) == length(data)
         data_out(end,i) = data(end-1,i);
      end
   end
   
   clear spike_inds;
end

%output despiked data if ini file selects it
if c.Spikes.despike.ON == 1
        data = data_out;
end

function c_out = config_default(c_in,c_in_field,val)

c_out = c_in;

if isfield(c_in.Spikes,c_in_field) & eval(['~isempty(c_in.Spikes.' c_in_field ')'])
    % do nothing
else
    eval(['c_out.Spikes.' c_in_field ' = val;']);
end

