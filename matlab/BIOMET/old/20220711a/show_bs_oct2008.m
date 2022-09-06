hardcopy=0;
% some BERMS plots for discussion
%cd 'D:\Nick\matlab\BS\results_oct08';
set_powerpt_slide_defaults;
colordef('white');
fr_biomet_sites_report(2000:2008,'BS','nep_filled_with_fits',0,'Cumulative NEP',0,0,0,[],[],[],0);
zoom on; %pause;
fr_biomet_sites_report(2000:2008,'BS','nep_filled_with_fits',5,'10-day mean NEP',3,3,0,[],10,[],0);
zoom on; %pause;
fr_biomet_sites_report(2000:2008,'BS','eco_photosynthesis_filled_with_fits',0,'Cumulative GEP',0,0,0,[],[],[],0);
zoom on; %pause;
fr_biomet_sites_report(2000:2008,'BS','eco_photosynthesis_filled_with_fits',5,'10-day mean GEP',3,3,0,[],10,[],0);
zoom on; %pause;
fr_biomet_sites_report(2000:2008,'BS','eco_respiration_filled_with_fits',0,'Cumulative R',0,0,0,[],[],[],0);
zoom on; %pause;
fr_biomet_sites_report(2000:2008,'BS','eco_respiration_filled_with_fits',5,'10-day mean R',3,3,0,[],10,[],0);
zoom on; %pause;
fr_biomet_sites_report(2000:2008,'BS','air_temperature_main',8,'10-day mean T_{air} (\circC)',0,0,0,[],10,[],0);
zoom on; %pause;
fr_biomet_sites_report(2000:2008,'BS','soil_temperature_main',8,'10-day mean T_{soil} (\circC)',0,0,0,[],10,[],0);
zoom on; %pause;
fr_biomet_sites_report(2000:2008,'BS','ppfd_downwelling_main',6,'10-day mean PAR',2,3,0,[],10,[],0);
zoom on; %pause;
fr_biomet_sites_report(2000:2008,'BS','precipitation',4,'Precipitation (mm)',0,0,0,[],[],[],0);
 zoom on; %pause;
%fr_biomet_sites_report(2000:2008,'PA','soil_moisture_main',8,'10-day mean VWC (m^3/m^3)',0,3,0,[],10,260);
%zoom on; %pause;

fig_beg = 21;
if hardcopy
    for k=1:18, 
        figure(k); 
        print(gcf,'-dmeta',['Figure ' num2str(k) ]); 
    end
    cumNEP_analysis('BS',2000:2008,10,fig_beg,1);
else
    cumNEP_analysis('BS',2000:2008,10,fig_beg,0);
end

% years=[2000:2006];
% for k=1:length(years)
%     gep=read_bor(fullfile(biomet_path(years(k),'BS'),'clean\ThirdStage\nep_filled_with_fits'));
%     ind=find(isnan(gep));
%     nn=length(ind);
%     disp(sprintf('%s  %d',num2str(years(k)),nn));
% end