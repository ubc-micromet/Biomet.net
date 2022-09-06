function [cumprecip_CRgf ]  = fill_CRcumprecip_with_OYgeonor(tv,cumprecip_CR,plots);

dv = datevec(tv(10));
year = dv(1);

doy = tv -datenum(year,1,0) - 8/24;
pth_OY = biomet_path(year,'OY');
cumprecip_OY = read_bor(fullfile(pth_OY,'Clean\SecondStage\precipitation_cumulative_geonor'));

fig = 0;
if plots
    fig = fig+1;
    figure(fig);
    plot(doy,cumprecip_CR,'b-',doy,cumprecip_OY,'r-');
    pause; zoom on;
end

% identify parts of the trace that should be filled with geonor
% data-- Jan-March and Nov-Dec.
ind_part1 = find(doy>=0 & doy < 91 );
ind_part2 = find(doy>=305 & doy< 366 );

% fill the first part by replacing the CR cumprecip trace with the OY
% geonor for that year, adjust the rest of the CR trace using the offset
% calculated between OY geonor and the cumprecip_CR trace

cumprecip_CRgf = cumprecip_CR;
cumprecip_CRgf(ind_part1) = cumprecip_OY(ind_part1);
offset1 = cumprecip_CRgf(max(ind_part1)) - cumprecip_CR(max(ind_part1));
cumprecip_CRgf(max(ind_part1)+1:end) = cumprecip_CRgf(max(ind_part1)+1:end) + offset1;

if plots
    fig = fig+1;
    figure(fig);
    plot(doy,cumprecip_CRgf,'b-',doy(ind_part1),cumprecip_OY(ind_part1),'r-');
    pause; zoom on;
end

% now fill the last part of the trace
%--------------------------------------
% first, correct for any offset that exists between the OY geonor and the
% CR cumprecip at the beginning of Nov

offset2 = cumprecip_OY(min(ind_part2)) - cumprecip_CRgf(min(ind_part2));
cumprecip_OY_shifted = cumprecip_OY;
cumprecip_OY_shifted(ind_part2) = cumprecip_OY(ind_part2)-offset2;

disp('............TBRG replaced with Geonor at OY for winter precipitation');

if plots
    fig = fig+1;
    figure(fig);
    plot(doy,cumprecip_CRgf,'b-',doy(ind_part1),cumprecip_OY(ind_part1),'r-',doy(ind_part2),cumprecip_OY_shifted(ind_part2),'r-');
    pause; zoom on;
end

cumprecip_CRgf(ind_part2) = cumprecip_OY_shifted(ind_part2);

