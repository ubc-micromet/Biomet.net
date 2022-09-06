function view_one_site(ind,year,siteID,Tcat,select)

% select: 1 = plot diagnostic figures only
%         0 = plot all figures
% Tcat: "Trace Category" selection vector for the category of traces that will plot
%		SiteID=PAOA, PAOB, PAOJ:
%			Tcat[1]: Climate/Diagnostics 1,plot 0,skip
%			Tcat[2]: Calibration Eddy 1,plot 0,skip
%			Tcat[3]: Calibration Profile 1,plot 0,skip
%			Tcat[4]: Eddy Correlation 1,plot 0,skip
%			Tcat[5]: Calibration Chambers 1,plot 0,skip
%			Tcat[6]: Chambers 1,plot 0,skip
%		SiteID=YF, OY, HJP02, HJP75:
%			Tcat[1]: Climate/Diagnostics 1,plot 0,skip
%			Tcat[2]: Eddy Correlation 1,plot 0,skip
%		SiteID=CR:
%			Tcat[1]: Climate/Diagnostics 1,plot 0,skip
%			Tcat[2]: Calibration Eddy 1,plot 0,skip
%			Tcat[1]: Calibration Profile 1,plot 0,skip
%			Tcat[2]: Eddy Correlation 1,plot 0,skip

if ~exist('select') | isempty(select);
    select = 0;
end

    close_all_Fig_but_200
    currentDate = datenum(year,1,0) + ind;

     try
   	switch upper(siteID)
      	case 'CR'
        		if Tcat(1)==1
               try
                  title_figure('Campbell River (Climate/Diagnostics)')
                  frbc_pl(ind,year,select);   
                  pause
                	title_figure('Close all?')
                	pause
           	 	catch
                	close_all_Fig_but_200
               end
           	end
        case 'PA'
         	if Tcat(1)==1
            	try
           			title_figure('PA Old Aspen (Climate/Diagnostics)')
                 	paoa_pl(ind,year,select);
              		pause
                	title_figure('Close all?')
                  pause
              	catch
                	close_all_Fig_but_200
               end
         	end
         case 'JP'
            if Tcat(1)==1
               try
           			title_figure('PA jack Pine (Climate/Diagnostics)')
                 	paoj_pl(ind,year,select);
              		pause
                	title_figure('Close all?')
                  pause
              	catch
                	close_all_Fig_but_200
               end
            end
         case 'BS'
            if Tcat(1)==1
            try
           			title_figure('PA Old Black Spruce (Climate/Diagnostics)')
                 	paob_pl(ind,year,select);
              		pause
                	title_figure('Close all?')
                  pause
              	catch
                	close_all_Fig_but_200
               end
            end
        case 'OY'
            if Tcat(1)==1
               try
                  title_figure('Campbell River Cutblock (Climate/Diagnostics)')
                 	plt_oy(ind,year,select);   
                	pause
                	title_figure('Close all?')
                	pause
                	close_all_Fig_but_200
           	 	catch
                	close_all_Fig_but_200
               end
            end
            if Tcat(2)==1
               try
                	title_figure('Campbell River Cutblock (Eddy Correlation)')
%                	oy_plt_fluxes(ind,year,select);
                	eddy_pl_new(ind,year,'OY',select);
                	pause
                	title_figure('Close all?')
                  pause
                  close_all_Fig_but_200
            	catch
                	close_all_Fig_but_200
                	return
               end
            end 
                close_all_Fig_but_200
            return
         case 'YF'%-----------------------------------------------------YF--------------------
            if Tcat(1)==1
               try
                  title_figure('Young Fir (Climate Data)')
                	YF_pl(ind,year,select);   
                	pause
                	title_figure('Close all?')
                	pause
                	close_all_Fig_but_200
            	catch
                  close_all_Fig_but_200
               end
            end
            if Tcat(2)==1
            	try
                	title_figure('Young Fir (Eddy Correlation)')
%                yf_plt_fluxes(ind,year,select);
                	eddy_pl_new(ind,year,'YF',select);
                	pause
                	title_figure('Close all?')
                  pause
                  close_all_Fig_but_200
            	catch
                  close_all_Fig_but_200
                  return
               end  
            end
            	close_all_Fig_but_200
               return
         case 'HJP02'%----------------------------------------------------HJP02----------------
            if Tcat(1)==1
               try
                  title_figure('HJP02 (Climate Data)')
                	HJP02_pl(ind,year,select);   
                	pause
                	title_figure('Close all?')
                	pause
                	close_all_Fig_but_200
            	catch
                	close_all_Fig_but_200
                end
            end
            if Tcat(2)==1
               try
                	title_figure('HJP02 (Eddy Correlation)')
                	HJP02_plt_fluxes(ind,year,'HJP02',1);
                	pause
                	title_figure('Close all?')
                  pause
                  close_all_Fig_but_200
            	catch
                	close_all_Fig_but_200
               	return
               end
            end
            close_all_Fig_but_200
            return  
             case 'HJP75'%----------------------------------------------------HJP75----------------
            if Tcat(1)==1
               try
                  title_figure('HJP75 (Climate Data)')
                	HJP75_pl(ind,year,select);   
                	pause
                	title_figure('Close all?')
                	pause
                	close_all_Fig_but_200
            	catch
                	close_all_Fig_but_200
                end
            end
            if Tcat(2)==1
               try
                	title_figure('HJP75 (Eddy Correlation)')
                	HJP02_plt_fluxes(ind,year,'HJP75',1);
                	pause
                	title_figure('Close all?')
                  pause
                  close_all_Fig_but_200
            	catch
                	close_all_Fig_but_200
               	return
               end
            end
            close_all_Fig_but_200
            return 
        end %switch
       % pause
       % title_figure('Close all?')
       % pause
    end %try
    
    close_all_Fig_but_200
    
    %---------------------------------------------------------Calibrations EC-------------------
    if (siteID=='CR'|siteID=='PA'|siteID=='BS'|siteID=='JP') & Tcat(2)==1
    	try
       	switch upper(siteID)
       		case 'PA'
          		title_figure('PA Old Aspen (Calibrations - EC Licor)')
       		case 'BS'
             	title_figure('PA Black Spruce (Calibrations - EC Licor)')
         	case 'JP'
             	title_figure('PA Jack Pine (Calibrations - EC Licor)')
         	case 'CR'
            	title_figure('Campbell River (Calibrations - EC Licor)')
       	end 
       	cal_pl(ind+1,year,siteID); 
       	pause
       	title_figure('Close all?')
       	pause
    	end
    end

    close_all_Fig_but_200
    
    %---------------------------------------------------------Calibrations Profile-------------------
    if (siteID=='CR'|siteID=='PA'|siteID=='BS'|siteID=='JP') & Tcat(3)==1
       try
       	switch upper(siteID)
       		case 'PA'
          		title_figure('PA Old Aspen (Calibrations - Profile Licor)')
       		case 'BS'
             	title_figure('PA Black Spruce (Calibrations - Profile Licor)')
         	case 'JP'
             	title_figure('PA Jack Pine (Calibrations - Profile Licor)')
         	case 'CR'
            	title_figure('Campbell River (Calibrations - Profile Licor)')
         end
        	cal_pl(ind+1,year,siteID,[],'PR'); 
        	pause
        	title_figure('Close all?')
        	pause
    	end
    end

    close_all_Fig_but_200
    
    %---------------------------------------------------------Eddy Correlation-------------------
    if (siteID=='CR'|siteID=='PA'|siteID=='BS'|siteID=='JP') & Tcat(4)==1
       try
       	switch upper(siteID)
       		case 'PA'
          		title_figure('PA Old Aspen (Eddy Correlation)')
       		case 'BS'
             	title_figure('PA Black Spruce (Eddy Correlation)')
         	case 'JP'
             	title_figure('PA Jack Pine (Eddy Correlation)')
         	case 'CR'
            	title_figure('Campbell River (Eddy Correlation)')
       	end 
        	eddy_pl(ind,year,siteID,select);
        	pause
        	title_figure('Close all?')
         pause
    	end
    end

    close_all_Fig_but_200
    
    %---------------------------------------------------------Calibrations Chamber-------------------
    if (siteID=='PA'|siteID=='BS'|siteID=='JP') & Tcat(5)==1
       try
       	switch upper(siteID)
       		case 'PA'
          		title_figure('PA Old Aspen (Calibrations - Chamber Licor)')
       		case 'BS'
             	title_figure('PA Black Spruce (Calibrations - Chamber Licor)')
         	case 'JP'
             	title_figure('PA Jack Pine (Calibrations - Chamber Licor)')
       	end
        	cal_pl(ind+1,year,siteID,[],'CH'); 
        	pause
        	title_figure('Close all?')
         pause
    	end
    end

    close_all_Fig_but_200
    
    %------------------------------------------------------------------Chambers-------------------
    if (siteID=='PA'|siteID=='BS'|siteID=='JP') & Tcat(6)==1
    	try
       	switch upper(siteID)
       		case 'PA'
          		title_figure('PA Old Aspen (Chambers)')
       		case 'BS'
             	title_figure('PA Black Spruce (Chambers)')
         	case 'JP'
             	title_figure('PA Jack Pine (Chambers)')
       	end
         chamber_pl(ind-1,year,siteID,select);
         pause
         title_figure('Close all?')
         pause
    	end
    end

    close_all_Fig_but_200

function title_figure(title_1)
    figure
    axes
    set(gca,'box','off','position',[0 0 1 1])
    text(0.1,0.5,title_1,'fontsize',28)
    drawnow