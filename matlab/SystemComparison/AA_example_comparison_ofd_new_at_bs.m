fr_set_site('bs','n');

Stats_Old = fcrn_load_external(datenum(2004,4,4:5),'bs','\\Fluxnet02\HFREQ_BS\MET-DATA\hhour\')

% Load the new data
cd C:\UBC_PC_Setup\Site_specific\BS_new_eddy

Stats_new = fcrn_load_data(datenum(2004,4,4:5),'bs')

Stats_all = fcrn_merge_stats(Stats_new,Stats_Old)

h = fcrn_plot_report(Stats_all,[],{'MainEddy','MainEddy_Old'})

ind_select = unique(sort([find_selected(h,Stats_all)]));

fcrn_plot_report(Stats_all,ind_select,{'MainEddy','MainEddy_Old'});
