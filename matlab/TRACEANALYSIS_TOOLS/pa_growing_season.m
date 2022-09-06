function [leafout,leafend] = PA_growing_season(Year)

if Year ==1994
   pth_db_2 = biomet_path('yyyy','PA','clean\thirdstage');
else
   pth_db_2 = biomet_path('yyyy','PA','clean\secondstage');
end   

clean_tv	   = read_bor([pth_db_2 'clean_tv'],8,[],Year,[],1);
tv_doy = convert_tv(clean_tv,'doy');

nee_main 	= read_bor([pth_db_2 'nee_main'],[],[],Year,[],1);
lai_hazel	= read_bor([pth_db_2 'lai_hazel'],[],[],Year,[],1);
lai_aspen	= read_bor([pth_db_2 'lai_aspen'],[],[],Year,[],1);
lai_aspen	= ta_interp_points(lai_aspen,48);
lai_hazel	= ta_interp_points(lai_hazel,48);
lai		   = lai_hazel+lai_aspen;

[nee_mean,ind_mean] = runmean(nee_main,5*48,48);
nee_mean(find(isnan(nee_mean))) = 0;
tv_nee = tv_doy(ind_mean);

[nee_sort,ind_sort] = sort(nee_mean);

grow = find((tv_nee(ind_sort)<160 | tv_nee(ind_sort)>250) & tv_nee(ind_sort)<290);

diff_to_max = abs( tv_nee(ind_sort(grow)) - tv_nee(ind_sort(grow(end))) );
ind_grow = find(diff_to_max>120);
leafing = tv_nee( ind_sort([grow(end) grow(ind_grow(end))]) );


leafout = floor(min(leafing));
leafend = ceil(max(leafing));

if nargout~=0
   return
end
   
   [leafout_org,leafend_org] = org_co2_parameters_v1999('pa',Year);

subplot('Position',subplot_position(2,1,1));
plot(tv_doy,[lai,lai_hazel,lai_aspen])
axis([0 365 0 5])
if exist('leafout_org')
   hold on
   plot([leafout_org leafout_org],[0 5],'k:');
   plot([leafend_org leafend_org],[0 5],'k:');
   hold off
end
hold on
plot([leafout leafout],[0 5],'r:');
plot([leafend leafend],[0 5],'r:');
hold off

subplot('Position',subplot_position(2,1,2));
plot(tv_doy(ind_mean),nee_mean)
axis([0 365 -8 5])
if exist('leafout_org')
   hold on
   plot([leafout_org leafout_org],[-8 5],'k:');
   plot([leafend_org leafend_org],[-8 5],'k:');
   hold off
end
hold on
plot([leafout leafout],[-8 5],'r:');
plot([leafend leafend],[-8 5],'r:');
hold off
