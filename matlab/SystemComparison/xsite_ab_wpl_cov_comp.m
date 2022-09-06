function xsite_ab_wpl_cov_comp
    cov_wT_xsite = NaN .* ones(20,1);
    cov_wT_ab_wpl = NaN .* ones(20,1);

for i = 1:20
    
    j = 2*(10+(i-1));
    currentDate = fr_round_hhour(datenum(2004,6,17) + j/96);
    disp(datestr(currentDate));
    
    fileName = fullfile('D:\met-data\data\040617',[fr_dateToFilename(currentDate+7/24) '.DX5']);
    sonic_xsite = FR_read_raw_data(fileName,5)';
    
    if ~isempty(sonic_xsite)
        sonic_xsite = sonic_xsite./100;
        w_avg_xsite(i) = mean(sonic_xsite(:,3));
        cov_wT_tmp = cov(sonic_xsite);
        
        cov_wT_xsite(i) = cov_wT_tmp(3,4);

        %if cov_wT_xsite(i) < 0.005
        %    cov_wT_xsite(i) = NaN;
        %end
    end
    
    [yy,dd,MM,hh,mm,ss] = datevec(fr_round_hhour(currentDate,1));
    [yy,dd,MM,hh,mm,ss] = datevec(datenum(yy,dd,MM,hh,mm-30,ss));
    doy = floor(datenum(yy,dd,MM,hh,mm,ss) - datenum(yy,1,0));
    fileName = sprintf('P%03.0f%02.0f%02.0f.SLT',doy,hh,mm);
    fileName = fullfile('D:\Experiments\AB-WPL\SiteData\data',fileName);
    sonic_ab_wpl = fr_read_AB_WPL_file(fileName);
    
    if ~isempty(sonic_ab_wpl)
        w_avg_ab_wpl(i) = mean(sonic_ab_wpl(:,3));
        cov_wT_tmp = cov(sonic_ab_wpl);
        cov_wT_ab_wpl(i) = cov_wT_tmp(3,4);
    end
    
end

plot_regression(cov_wT_xsite,cov_wT_ab_wpl)

return