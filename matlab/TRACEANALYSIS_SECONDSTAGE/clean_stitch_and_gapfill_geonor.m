function [ppt_geonor] = clean_stitch_and_gapfill_geonor(siteId,year,tv,P_geonor,pptTBRG1,pptTBRG2,pptTBRGavg,fill_beg,fill_ed,plots,hcop);

% Cleans the Geonor trace by calling functions to remove offsets due to bucket emptying,
% gapfills with calibrated TBRG data during the warm season, and
% **** during the cold season

% Nick                          file created:  Jan 15, 2008
%                               Last modified: Feb 4, 2010
%
% Revisions:
% Feb 4, 2010 (Nick)
%    -added Zoran's trick for handling noise in the signal


% set the default warm season to be April 1 to Oct 30.

disp('====================== GEONOR gap-filling results ======================');

arg_default('fill_beg',90);
arg_default('fill_ed',300);

% use the TBRG mean trace to calibrate and gap-fill the Geonor, except in
% 2005 and 2006 when TBRG1 was unreliable. Use the month of May to do the
% regression
if strcmp(upper(siteId),'OY')
    switch year
        case 2004
            pptTBRG = pptTBRGavg;
            doy_calst = 120;
            doy_caled = 150;
        case 2005
            pptTBRG = pptTBRG2;
            doy_calst = 120;
            doy_caled = 150;
        case 2006
            pptTBRG = pptTBRG2;
            fill_beg = 39; % moved fill with TBRG period earlier to account for missed precip DOY39-68
            doy_calst = 250;
            doy_caled = 270;
        case 2007
            pptTBRG = pptTBRGavg;
            doy_calst = 120;
            doy_caled = 150;
        otherwise
            pptTBRG = pptTBRGavg;
            doy_calst = 120;
            doy_caled = 150;
    end
else
    pptTBRG = pptTBRGavg;
    doy_calst = 120;
    doy_caled = 150;
end

pth = biomet_path(year,siteId);
%P_geonor = read_bor(fullfile(pth,'climate\OY_ClimT\Pre_avg'));

%tv = read_bor(fullfile(pth,'Climate\Clean\clean_tv'),8);
doy = tv-datenum(year,1,0)-8/24;

if plots
    figure(1); plot(doy,P_geonor,'g-'); 
    title(['Geonor trace after manual cleaning: ' siteId ' ' num2str(year) ]);
    hold on; pause;
end

% there are two kinds of gaps in the geonor trace--gaps following bucket
% emptying and the gaps remaining after data collected during periods of
% instrument malfunctioning are removed.  One way to produce a relatively
% clean set of traces that are offset is to do the following:

%%%%%%%%%%%%%%%%
%"MANUAL" CLEAN
%%%%%%%%%%%%%%%%

% there is no way around doing a manual clean on the Geonor trace--finding
% an algorithm to clean everything is impossible. But this comes fairly
% close

%clean the trace by knocking out problems with datalogger
ind_clean = find(P_geonor<=0);
P_geonor(ind_clean)=NaN;
P_geonor_diff = diff(P_geonor);

ind = find(P_geonor_diff>50 | P_geonor_diff<-50); % finds jumps that are larger than the noise we have been observing in the instrument
ind_bad = ind+1; % add one to the indexes since diff(i) = x(i+1)-x(i)
ppt_tst = P_geonor;
ppt_tst(ind_bad) = NaN; % knock out all of these spikes
ind_zero = find(P_geonor==0); 
ppt_tst(ind_zero)=NaN; % knocks out points equal exactly to zero
for k=2:length(ppt_tst-1), 
    if isnan(ppt_tst(k-1)) & ~isnan(ppt_tst(k)) & isnan(ppt_tst(k+1)) 
        ppt_tst(k)=NaN; % knocks out remaining "stranded" points (could be done by hand in the cleaning tool)
    end
end
ppt_manclean = ppt_tst;

if plots
    plot(doy,ppt_tst,'b-'); 
    title(['Geonor trace after Nick''s additional cleaning: ' siteId ' ' num2str(year) ]);hold off; pause;
end

% now we have to identify offsets from bucket tipping and offsets from lack
% of data (i.e. gaps that should be filled with TBRG data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND BUCKET EMPTYING EVENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ppt_tst,ind_emptied]= find_geonor_bucket_empties(doy,ppt_tst,-100);

% remove offset due to the bucket having water in it on Jan 1.
% use the first non-NaN value of the year to correct

ind = find(~isnan(ppt_tst));
ppt_tst = ppt_tst-ppt_tst(min(ind));
if plots
    plot(doy,ppt_tst,'r-');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GAP-FILL WITH TBRG calibrated to GEONOR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% where possible (i.e. during growing season, when snow isn't falling),
% fill gaps with TBRG data

ind_gs = find(doy > fill_beg & doy < fill_ed);
ind_nan= find(isnan(ppt_tst));
ind_fill = intersect(ind_gs,ind_nan);

ind = find(isnan(pptTBRG));
pptTBRG(ind)=0;
ppt_geonor = ppt_tst;

if plots
    figure(2);
end

[a] = calibrate_TBRG_to_geonor(doy,doy_calst,doy_caled,pptTBRG,ppt_geonor,ind_fill,plots);

% do the gap-filling
i=1;
while i<length(ind_fill)
    s=1;
    while ind_fill(i+s)-ind_fill(i+s-1) == 1   %isnan(ppt_tst(ind_fill(i)+s))
        if i+s < length(ind_fill)
          s=s+1;
        else
          break
        end
    end
    ppt_geonor(ind_fill(i:i+s)) = ppt_geonor(ind_fill(i)-1)+a(1).*cumsum(pptTBRG(ind_fill(i:i+s)));
    i=i+s;
end
disp(['Total points filled: ' num2str(i)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RECHECK FILLED GEONOR TRACE FOR BUCKET EMPTIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ppt_geonor,ind_emptied]= find_geonor_bucket_empties(doy,ppt_geonor,-20);


% add Zoran's trick for handling noise in the signal, Feb 4, 2010

for i=2:length(ppt_geonor)
    if ppt_geonor(i-1)>=ppt_geonor(i) || ppt_geonor(i) ==0
        ppt_geonor(i)=ppt_geonor(i-1);
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LINEARLY INTERPOLATE ANY COLD SEASON GAPS UP TO 14 DAYS IN LENGTH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ppt_geonor,index] = ta_interp_points(ppt_geonor,14*48);

if plots
    % zero any remaining NaNs in the TBRG traces
    ind = find(isnan(pptTBRG1));
    pptTBRG1(ind) = 0;
    ind = find(isnan(pptTBRG2));
    pptTBRG2(ind) = 0;
    
    figure(3);
    plot(doy,P_geonor,'g-',doy,ppt_manclean,'b-',doy,ppt_geonor,'c-',doy,ppt_tst,'r-',...
        doy,cumsum(pptTBRG1),'k-',doy,cumsum(pptTBRG2),'m-');
    hh = get(gca,'Children');
    set(hh(4),'LineWidth',2);
    set(hh(4),'Color',[ 0.000 0.000 0.627 ]);
    set(hh(2),'Color',[ 0.000 0.502 0.251 ]);
    xlabel('DOY');
    ylabel('Rainfall or Precip (mm)');
    title([ 'Geonor trace cleaning: ' siteId ' ' num2str(year) ]);
    legend('Geonor_{after manual cleaning}','Geonor_{Nick additional cleaning}','Geonor_{filled and stitched}','Geonor_{stitched}','TBRG1','TBRG2',2);
    if hcop
        print('-dmeta',[ siteId '_' num2str(year) '_precip_summary' ]);
    end
end


disp('====================== end GEONOR gap-filling results ======================');