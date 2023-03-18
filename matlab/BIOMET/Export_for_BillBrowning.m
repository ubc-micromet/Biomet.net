function Export_for_BillBrowning

% one time export for student Billy Browning Geog.
yearsIn = 2022:2023;
try
    fprintf('Started: %s\n',mfilename);

    % If yearsIn are not given, then
    % export this year and the previous year 
    dateVecNow = datevec(floor(now));
    yearNow = dateVecNow(1);
    if ~exist('yearsIn','var') | isempty(yearsIn) %#ok<*OR2>
        yearsIn = yearNow-1:yearNow;          %  last year and this year
    end

    % loop for both years
    for currentYear = yearsIn
        outputFileName = 'TotemDataB_%d.dat';
        pathOut = fullfile('D:\Sites\web_page_weather',sprintf(outputFileName,currentYear));

        % Use the following one to export most of the data
        pathTotem = biomet_path('yyyy','UBC_Totem','Clean/ThirdStage'); %sprintf('//annex001/database/%d/UBC_Totem/Climate/Totem1/',yearX);
        pathRadiation = biomet_path('yyyy','UBC_Totem','Radiation/30min');

        % Totem is in GMT.  Output will be in PST so convert the time and truncate
        % the data.
        if currentYear == yearNow
            yearRange = currentYear;
        else
            yearRange = currentYear:currentYear+1;
        end
        tv_T  =  read_bor(fullfile(pathTotem,'clean_tv'),8,[],yearRange)-8/24;   % GMT -> PST!
        Ta =  read_bor(fullfile(pathTotem,'air_temperature_main'),[],[],yearRange);       % Tair
        RH =  read_bor(fullfile(pathTotem,'relative_humidity_main'),[],[],yearRange);
        Tsoil_10 =  read_bor(fullfile(pathTotem,'soil_temperature_10cm'),[],[],yearRange);
        Tsoil_20 =  read_bor(fullfile(pathTotem,'soil_temperature_20cm'),[],[],yearRange);
        Tsoil_40 =  read_bor(fullfile(pathTotem,'soil_temperature_40cm'),[],[],yearRange);
        global_radiation_main =  read_bor(fullfile(pathTotem,'global_radiation_main'),[],[],yearRange);
        precipitation =  read_bor(fullfile(pathTotem,'precipitation_main'),[],[],yearRange);
        wind_speed_main =  read_bor(fullfile(pathTotem,'wind_speed_main'),[],[],yearRange);
        wind_direction_main =  read_bor(fullfile(pathTotem,'wind_direction_main'),[],[],yearRange);
        longWaveIn = read_bor(fullfile(pathRadiation,'MET_PIR_LWi_Avg'),[],[],yearRange);


        ind = find(tv_T>datenum(currentYear,1,1) & tv_T <= datenum(currentYear+1,1,1) & tv_T < now-1/24);

        tv_T = tv_T(ind);
        Ta = Ta(ind);
        RH = RH(ind);
        RH(RH>100) = 100;           % clamp RH to 100%
        Tsoil_10 = Tsoil_10(ind);
        Tsoil_20 = Tsoil_20(ind);
        Tsoil_40 = Tsoil_40(ind);
        precipitation = precipitation(ind);
        global_radiation_main = global_radiation_main(ind);
        wind_speed_main = wind_speed_main(ind);
        wind_direction_main = wind_direction_main(ind);
        longWaveIn = longWaveIn(ind);

        %% fill the gaps:
        %Ta_fill = interp1(tv_T(~isnan(Ta)),Ta(~isnan(Ta)),tv_T);

        %%
        formatX='%s, %6.2f, %6.2f, %6.2f, %6.2f, %6.2f, %6.2f, %6.2f, %6.2f, %6.2f %6.2f \n';
        fid=fopen(pathOut,'w');
        %fid=2;
        if fid> 0
            fprintf(fid,'Totem Field Climate Station Data \n\n');
            fprintf(fid,'(c)%d, Biometeorology and Soil Physics Group, University of British Columbia \n\n',yearNow);
            fprintf(fid,'Time stamp marks the end of the measurement period\n');
            fprintf(fid,'Date/Time,Ta (degC),RH (%s), precipitation (mm), global_radiation_main (W/m2), Tsoil_10 (degC), Tsoil_20 (degC), Tsoil_40 (degC),wind_speed (m/s), wind_direction (deg),  long_wave_in (W/m2)  \n','%');
               for n=1 : max(size(tv_T))
                  fprintf(fid, formatX, datestr(tv_T(n),31),...
                              Ta(n),...
                              RH(n),...
                              precipitation(n),...
                              global_radiation_main(n),...
                              Tsoil_10(n),...
                              Tsoil_20(n),...
                              Tsoil_40(n),...
                              wind_speed_main(n),...
                              wind_direction_main(n),...
                              longWaveIn(n));
               end
            fclose(fid);
        end
    end
catch
    fprintf('*** Error in: %s ***\n',mfilename);
end
fprintf('Finished: %s\n',mfilename);    