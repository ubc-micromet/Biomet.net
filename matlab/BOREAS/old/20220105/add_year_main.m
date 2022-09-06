function view_one_site(ind,year,siteID)

    close_all_Fig_but_200
    currentDate = datenum(year,1,0) + ind;
    try
        switch upper(siteID)
            case 'CR',title_figure('Campbell River (climate data)')
                  frbc_pl(ind,year);
            case 'PA',title_figure('PA Old Aspen (climate data)')
                  paoa_pl(ind,year);
            case 'JP',title_figure('PA Old Jack Pine (climate data)')
                  paoj_pl(ind,year);
            case 'BS',title_figure('PA Old Black Spruce (climate data)')
                  paob_pl(ind,year);   
            case 'OY',title_figure('Campbell River Cutblock (climate & flux data)')
                  plt_oy(ind,year);                       
                  return
            case 'YF',title_figure('Young Fir (climate data)')
                  try
                      YF_pl(ind,year);   
%                      pause
                      title_figure('Close all?')
                      pause
                  catch
                      close_all_Fig_but_200
                  end
                  try
                      title_figure('Eddy correlation')
                      yf_plt_fluxes(ind,year);
%                      pause
                      title_figure('Close all?')
                      pause
                  catch
                      close_all_Fig_but_200
                      return
                  end
                  close_all_Fig_but_200
                  return
        end
        pause
        title_figure('Close all?')
        pause
    end

    close_all_Fig_but_200

    try
        title_figure('Calibrations')
        cal_pl(ind+1,year,siteID); 
        pause
        title_figure('Close all?')
        pause
    end

    close_all_Fig_but_200

    try
        title_figure('Eddy correlation')
        eddy_pl(ind-1,year,siteID);
        pause
        title_figure('Close all?')
        pause
    end

    close_all_Fig_but_200


function title_figure(title_1)
    figure
    axes
    set(gca,'box','off','position',[0 0 1 1])
    text(0.1,0.5,title_1,'fontsize',28)
    drawnow