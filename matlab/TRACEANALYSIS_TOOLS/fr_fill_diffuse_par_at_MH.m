function [par_diff_calc] = fr_fill_diffuse_par_at_MH(year,doy_fit,tv,par_tot,par_diff,show_fig)

pth_site = biomet_path(year,'MH');

% conversion factor for deg to rads (must use with MATLAB trig functions)
conv_rad = pi/180;

lat = 48.612;
long = 123.576;

% solar constant
S0   = 1360;          % W/m2
conv = 1/0.468;       % W/m2 to umol/m2/s

tv_loc   = tv - 8/24;
[year,mon,day,hr,min,sec] = datevec(tv_loc);
doy_loc  = tv_loc - datenum(2006,1,0);
doy_now  = now - datenum(2006,1,0) - 8/24;

solzen_deg = NaN*ones(length(tv_loc),1);
R          = NaN*ones(length(tv_loc),1);

% note: solar zenith angle is calculated for the middle of the hhour
for i=1:length(tv_loc)
    [t_sr,t_sr_solar,t_ss,t_solnoon,daylength,solzen_deg(i),decl] = solar_tim(lat,long,...
                                                                    floor(doy_loc(i)),hr(i)+(min(i)-15)/60+sec(i)/3600,0,0);
     R(i) = par_tot(i)/( conv*S0*cos(conv_rad*solzen_deg(i)));
       if R(i) < 0 | R(i) > 1
           R(i) = NaN;
       end
end

% now fit a 4th order polynomial to a clear day's data (doy_fit)

low_par = 30;  % lowest observed par value used in the fit

Qdiff = inline('A(1) + A(2).*Z + A(3).*Z.^2 +  A(4).*Z.^3 + A(5).*Z.^4','A','Z');

ind_fit = find(floor(doy_loc) == doy_fit & R <= 0.8 & par_tot > low_par);
A0 = [ 1 1 1 1 1 ]; 
[A_fit,Qdiff_mod,fit_params] = fr_function_fit(Qdiff,A0,par_diff(ind_fit)./par_tot(ind_fit),[],R(ind_fit));

% convert fitted function values to diffuse PAR

for i=1:length(tv_loc)
        if R(i) > 0 & R(i) <= 0.8
            par_diff_calc(i) = par_tot(i)*(A_fit(1) + A_fit(2)*R(i) + A_fit(3)*R(i)^2 + A_fit(4)*R(i)^3 + A_fit(5)*R(i)^4 );
        elseif R(i) > 0.8
            par_diff_calc(i) = par_tot(i) * 0.130;
%         else
%             par_diff_calc(i) = NaN;
        end
end

ind_gap = find(isnan(par_tot));
par_diff_calc(ind_gap) = NaN;

if show_fig
    fig=0;
    fig=fig+1; figure(fig);
    plot(doy_loc(ind_fit),par_diff(ind_fit),'b-',doy_loc(ind_fit),par_diff_calc,'ro');
    title([ upper(siteID) ' Diffuse PAR Measured and Modelled for DOY ' num2str(doy_fit) ', 2006']);
    legend('BF2_{diffuse}','Modelled diffuse');
    xlim = get(gca,'XLim');
    xloc = xlim(1) + 0.05;
    text(xloc,225,['A0 = ' num2str(A_fit(1)) ],'FontSize',14);
    text(xloc,210,['A1 = ' num2str(A_fit(2)) ],'FontSize',14);
    text(xloc,195,['A2 = ' num2str(A_fit(3)) ],'FontSize',14);
    text(xloc,180,['A3 = ' num2str(A_fit(4)) ],'FontSize',14);
    text(xloc,165,['A4 = ' num2str(A_fit(5)) ],'FontSize',14); 
    zoom on; 
end