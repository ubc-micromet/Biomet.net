function [slope,intercept] = OR_CR_calibrate(FIG);

arg_default('FIG',0);

% load data
[cr, tv] = read_db(2004,'CR','\climate\clean','radiation_shortwave_downwell3_cnr1_45m');
or = read_db(2004,'OR','\climate\or1','Solar_AVG');

% pick clear days
tv = datenum(datevec(tv-8/24)); %GMT shift
ind_ok = find(tv >= datenum(2004,1,167) & tv <= datenum(2004,1,173)); % get clear days
% clear days are 274-278, 210-215, and 167-173 (Feb 3 2005)
cr = cr(ind_ok); or = or(ind_ok);

% figure;
% plot([cr or]);
% title('Check smoothness of both');

dv = datevec(tv(ind_ok));
ind_md = find(dv(:,4) > 9 & dv(:,4) < 15); % get midday values
ind_hi = find(cr >= 500); % get high values
ind_up = find(cr >0 ); % get all daytime

% [curve, gof] = fit(or(ind_md),cr(ind_md),'poly1');
% figure;
% plot(cr(ind_md),or(ind_md),'k.','MarkerSize',6);
% hold on;
% plot(curve,'k-');
% legend('hide');
% ylabel('SW\downarrow_{CR}');
% xlabel('SW\downarrow_{OR}');
% title(['Midday only -- RMSE: ' num2str(gof.rmse,3) ' R^2: ' num2str(gof.rsquare,3) ' Slope: ' num2str(curve.p1,3) ' Intercept: ' num2str(curve.p2,3)]);
% title('Midday values only');

% try
% [curve, gof] = fit(or(ind_hi),cr(ind_hi),'poly1');
% figure;
% plot(cr(ind_hi),or(ind_hi),'k.','MarkerSize',6);
% hold on;
% plot(curve,'k-');
% legend('hide');
% ylabel('SW\downarrow_{CR}');
% xlabel('SW\downarrow_{OR}');
% title(['High (>500) only -- RMSE: ' num2str(gof.rmse,3) ' R^2: ' num2str(gof.rsquare,3) ' Slope: ' num2str(curve.p1,3) ' Intercept: ' num2str(curve.p2,3)]);
% end

[curve, gof] = fit(or(ind_up),cr(ind_up),'poly1');

if FIG == 1
figure;
plot(or(ind_up),cr(ind_up),'k.','MarkerSize',6);
hold on;
plot(curve,'k-');
legend('hide');
ylabel('SW\downarrow_{CR}');
xlabel('SW\downarrow_{OR}');
title(['All daytime -- RMSE: ' num2str(gof.rmse,3) ' R^2: ' num2str(gof.rsquare,3) ' Slope: ' num2str(curve.p1,3) ' Intercept: ' num2str(curve.p2,3)]);
end

slope = curve.p1;
intercept = curve.p2;