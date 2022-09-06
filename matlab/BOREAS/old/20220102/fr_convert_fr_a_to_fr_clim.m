function fr_convert_fr_a_to_fr_clim
    year = 2001;
    pth  = biomet_path(year,'CR','cl');            % get the climate data path

    % Find logger ini files
    ini_climMain = fr_get_logger_ini('cr',year,'fr_clim','fr_clim_105');   % main climate-logger array
    ini_clim2    = fr_get_logger_ini('cr',year,'fr_clim','fr_clim_106');   % secondary climate-logger array
    ini_soilMain = fr_get_logger_ini('cr',year,'fr_soil','fr_soil_101');   % main soil-logger array
    ini_fr_a     = fr_get_logger_ini('cr',year,'fr_a','fr_a');             % fr_a array
    ini_fr_c     = fr_get_logger_ini('cr',year,'fr_c','fr_c');             % fr_a array

if 1==0
    h = waitbar(0,'Copying files...');
    for i = 2:length(ini_fr_a.TraceName)
        dd = char(upper(ini_fr_a.TraceName(i)));
        ind1 = find(strcmp(upper(ini_fr_a.TraceName(i)),upper(ini_climMain.TraceName)));
        ind2 = find(strcmp(upper(ini_fr_a.TraceName(i)),upper(ini_clim2.TraceName)));
        ind3 = find(strcmp(upper(ini_fr_a.TraceName(i)),upper(ini_soilMain.TraceName)));
        if isempty(ind1) & isempty(ind2) & isempty(ind3) 
            disp(sprintf('%d ->       %s',i,upper(char(dd))));
        else
            if ~isempty(ind1)
                for j=1:length(ind1)
                    sourceName = fr_logger_to_db_fileName(ini_fr_a, dd, pth);
                    destinationName = fr_logger_to_db_fileName(ini_climMain, char(ini_climMain.TraceName(ind1(j))), pth);
                    fr_copy_db_trace(sourceName,destinationName);
                end
            end
            if ~isempty(ind2)
                for j=1:length(ind2)
                    sourceName = fr_logger_to_db_fileName(ini_fr_a, dd, pth);
                    destinationName = fr_logger_to_db_fileName(ini_clim2, char(ini_clim2.TraceName(ind2(j))), pth);
                    fr_copy_db_trace(sourceName,destinationName);
                end
            end
            if ~isempty(ind3)
                for j=1:length(ind3)
                    sourceName = fr_logger_to_db_fileName(ini_fr_a, dd, pth);
                    destinationName = fr_logger_to_db_fileName(ini_soilMain, char(ini_soilMain.TraceName(ind3(j))), pth);
                    fr_copy_db_trace(sourceName,destinationName);
                end
            end
        end
        h = waitbar(i/length(ini_fr_a.TraceName));
    end
    delete(h);
 end
    h = waitbar(0,'Copying files...');
    for i = 2:length(ini_fr_c.TraceName)
        dd = char(upper(ini_fr_c.TraceName(i)));
        ind1 = find(strcmp(upper(ini_fr_c.TraceName(i)),upper(ini_climMain.TraceName)));
        ind2 = find(strcmp(upper(ini_fr_c.TraceName(i)),upper(ini_clim2.TraceName)));
        ind3 = find(strcmp(upper(ini_fr_c.TraceName(i)),upper(ini_soilMain.TraceName)));
        if isempty(ind1) & isempty(ind2) & isempty(ind3) 
            disp(sprintf('%d ->       %s',i,upper(char(dd))));
        else
            if ~isempty(ind1)
                for j=1:length(ind1)
                    sourceName = fr_logger_to_db_fileName(ini_fr_c, dd, pth);
                    destinationName = fr_logger_to_db_fileName(ini_climMain, char(ini_climMain.TraceName(ind1(j))), pth);
                    fr_copy_db_trace(sourceName,destinationName);
                end
            end
            if ~isempty(ind2)
                for j=1:length(ind2)
                    sourceName = fr_logger_to_db_fileName(ini_fr_c, dd, pth);
                    destinationName = fr_logger_to_db_fileName(ini_clim2, char(ini_clim2.TraceName(ind2(j))), pth);
                    fr_copy_db_trace(sourceName,destinationName);
                end
            end
            if ~isempty(ind3)
                for j=1:length(ind3)
                    sourceName = fr_logger_to_db_fileName(ini_fr_c, dd, pth);
                    destinationName = fr_logger_to_db_fileName(ini_soilMain, char(ini_soilMain.TraceName(ind3(j))), pth);
                    fr_copy_db_trace(sourceName,destinationName);
                end
            end
        end
        h = waitbar(i/length(ini_fr_c.TraceName));
    end
    delete(h);


function fr_copy_db_trace(sourceName,destinationName);

    fidIn = fopen(sourceName,'rb');
    fidOut = fopen(destinationName,'wb');
    dataIn = fread(fidIn,[1,Inf],'uchar');
    fwrite(fidOut,dataIn,'uchar');
    fclose(fidIn);
    fclose(fidOut);
