function [n_out,t_wp_out,len_spec_bins_out] = transfer_function(u_mean,print_flag)
%-------------------------------------------------------------------               
% calculate the theoretical values of the transfer functions following
% Moncrieff et al., 1997; Aubinet et al., 2000
% 10/05/02 natascha kljun
%-------------------------------------------------------------------               

if ~exist('print_flag')
   print_flag = 0;
end
if ~exist('u_mean') | isempty(u_mean)
	u_mean    = 2.0;      % (m/s) mean wind speed
end

%-------------------------------------------------------------------               
% all input values from Humphreys 1999 (MSc Thesis)
%-------------------------------------------------------------------               
n_s       = 20.83;    % (Hz) sample frequency 

Gamma     = 500;      % (s) time constant of running mean filter - not used in UBC Biomet system
t_r_sonic = 1/n_s;    % (s) response time of sonic (freq. response 20.83Hz from analog filter?)
t_r_irga  = 0.1;      % (s) response time of irga (freq. response 2Hz?)
pl        = 0.15;     % (m) sonic path length 
s         = 0.3;      % (m) maximum sensor separator distance, 0.4 for open path, 0.3 for closed path 
r         = 0.002;    % (m) tube radius (1/4" Dekabon tubing)
x         = 4;        % (m) tube length
d_c       = 1.48e-5;  % (m^2/s molec. diffusion coefficient of CO2 in air at 10C: 1.39e-5*(T[K]/273.15)^1.75
nu        = 1.461e-5; % (m^2/s) kinematic viscosity of air

%-------------------------------------------------------------------               
% normalize frequency
%-------------------------------------------------------------------               
[n,len_spec_bins,spec_bins] = fr_config_spec(100,20,2^15,n_s); % (Hz) natural frequency

% first blow up vectors to match spectra
n      = ones(length(u_mean),1) * n';
u_mean = u_mean * ones(1,length(len_spec_bins));

f_p    = n.*pl./u_mean;       % normalised frequency
f_s    = n.*s./u_mean;        % normalised frequency

%-------------------------------------------------------------------               
% calculate transfer function after Moncrieff et al., 1997
%-------------------------------------------------------------------               

u_t       = (0.009/60)/(pi*r^2); % (m/s) velocity in tube (9l/min / (2*pi*r^2) = 0.009/60 m^3/s / (2*pi*r^2))
t_t       = x/u_t;               % time for air parcel to travel through tube
re        = u_t*2*r/nu;          % reynolds number
d_t       = 1/n_s;               % (s) time interval between samples
eta       = exp(-d_t/Gamma);
tau_r     = eta/(n_s*(1-eta));   % effective time constant

t_r       = 2.*pi.*n.*tau_r./sqrt(1+(2.*pi.*n.*tau_r).^2./eta);                       % recursive digital running mean
t_r       = 1.*ones(size(n));;                                                                        % because no recursive digital running mean use in UBC system
t_d_sonic = 1./sqrt(1+(2.*pi.*n.*t_r_sonic).^2);                                      % sensor dynamic frequency response irga
t_d_irga  = 1./sqrt(1+(2.*pi.*n.*t_r_irga).^2);                                       % sensor dynamic frequency response sonic
t_m       = (1+(2.*pi.*n).^2.*t_r_sonic.*t_r_irga)./...
            sqrt((1+(2.*pi.*n.*t_r_sonic).^2).*(1+(2.*pi.*n.*t_r_irga).^2));          % sensor response mismatch
t_w       = 2./pi./f_p.*(1+exp(-2.*pi.*f_p)./2-3.*(1-exp(-2.*pi.*f_p))./(4.*pi.*f_p));% sonic anemometer path averaging
t_s       = real(exp(-9.9.*f_s.^1.5));                                                      % sensor separation loss (Moncrieff)
t_t_lamin = exp(-(pi.*r.*n).^2.*t_t./(6.*d_c));                                       % frequency attenuation, assuming laminar flow
t_t_turb_wrong = exp(-160.*re.*r.*n.^2.*x./u_t.^2);                                        % frequency attenuation, assuming turbulent flow (Moncrieff et al.,1997); wrong, cf. Aubinet p.141
t_t_turb  = exp(-80.*(re.^(-1/8)).*r.*n.^2.*x./u_t.^2);                               % frequency attenuation, assuming turbulent flow (Aubinet et al.,2000)
t_wp      = t_r.*t_d_irga.*t_d_sonic.*t_m.*t_w.*t_s.*t_t_turb;                        % total transfer function




if nargout > 0
   n_out    = n;
   t_wp_out = t_wp;
   len_spec_bins_out = len_spec_bins;
	return   
else
	close all
end

u_t2       = (0.008/60)/(pi*r^2);
re2        = u_t2*2*r/nu;
x2         = 8; %m
t_t_turb2  = exp(-80.*(re2.^(-1/8)).*r.*n.^2.*x2./u_t2.^2);

u_t3       = (0.008/60)/(pi*r^2);
re3        = u_t3*2*r/nu;
x3         = 12; %m
t_t_turb3  = exp(-80.*(re3.^(-1/8)).*r.*n.^2.*x3./u_t3.^2);

%-------------------------------------------------------------------               
% figures
%-------------------------------------------------------------------               

figure

subplot('Position',subplot_position(2,2,1));
semilogx(n,t_d_sonic,'r',...
         n,t_d_irga,'b',...
         n,t_m,'g');
axis([1e-3 10 0.0 1.1]);
subplot_label(gca,2,2,1,[0.001 0.01 0.1 1 10],[0:0.2:1])
hold on
plot([0.003 0.008],[0.6 0.6],'r');
text(0.01,0.6, 'sonic dynamic freq. resp.' ,'FontSize',8);
plot([0.003 0.008],[0.5 0.5],'b');
text(0.01,0.5,'IRGA dynamic freq. resp.','FontSize',8);
plot([0.003 0.008],[0.4 0.4],'g');
text(0.01,0.4, 'sensor response mismatch','FontSize',8);

subplot('Position',subplot_position(2,2,2));
semilogx(n,t_w,'r',...
         n,t_s,'b',...
         n,t_t_turb,'g');
axis([1e-3 10 0.0 1.1]);
subplot_label(gca,2,2,2,[0.001 0.01 0.1 1 10],[0:0.2:1])
hold on
plot([0.003 0.008],[0.6 0.6],'r');
text(0.01,0.6, 'sonic path averaging','FontSize',8);
plot([0.003 0.008],[0.5 0.5],'b');
text(0.01,0.5,'sensor separation','FontSize',8);
plot([0.003 0.008],[0.4 0.4],'g');
text(0.01,0.4,'tube loss (turbulent flow)','FontSize',8);


subplot('Position',subplot_position(2,2,3));
semilogx(n,t_wp,'r');
axis([1e-3 10 0.0 1.1]);
subplot_label(gca,2,2,3,[0.001 0.01 0.1 1 10],[0:0.2:1])
hold on
plot([0.003 0.008],[0.6 0.6],'r');
text(0.01,0.6, 'combined','FontSize',8);

subplot('Position',subplot_position(2,2,4));
semilogx(n,t_t_turb,'r',...
         n,t_t_turb2,'b',...
         n,t_t_turb3,'g');
axis([1e-3 10 0.0 1.1]);
hold on
subplot_label(gca,2,2,4,[0.001 0.01 0.1 1 10],[0:0.2:1])
plot([0.003 0.008],[0.6 0.6],'r');
text(0.01,0.6, 'tube loss (turbulent flow, 4m)','FontSize',8);
plot([0.003 0.008],[0.5 0.5],'b');
text(0.01,0.5,'tube loss (turbulent flow, 8m)','FontSize',8);
plot([0.003 0.008],[0.4 0.4],'g');
text(0.01,0.4,'tube loss (turbulent flow, 12m)','FontSize',8);

% Axis labels
axes('Position',subplot_position(1,1,1),'Visible','off');
text(0.5,-0.06,'Frequency (Hz)','HorizontalA','center','VerticalA','top');
text(-0.07,0.5,'C_{wC}(corrected)/C_{wC}(uncorrected)','Rotation',90,'HorizontalA','center','VerticalA','bottom');

if print_flag == 1 % color printing
   opts = struct('Format','meta','FontMode','scaled','FontSize',1.2,...
      'Color','cmyk','LineMode','scaled','LineWidth',3);
elseif print_flag == 2 % bw printing
   opts = struct('Format','eps','Preview','tiff','FontMode','scaled','FontSize',1,...
      'Color','bw','LineMode','scaled');
end

if print_flag > 0
   max_win = kais_poster_figsize; % This is the size of a maximized window on annex002
   set(gcf,'Position',max_win,'Color','none');
   exportfig(gcf,[kais_projekte 'FluxCalc\Transfunc_components_' num2str(u_mean(1)) 'ms-1'],opts);
end

return

