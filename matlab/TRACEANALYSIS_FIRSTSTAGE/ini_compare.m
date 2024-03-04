SiteID = 'BB2';
Stage = 'Second';
tic;
fprintf('Reading Old File')
ini_file_old=fullfile(db_pth_root,'Calculation_Procedures\TraceAnalysis_ini\',SiteID,sprintf('%s_%sStage_oldFormat.ini',SiteID,Stage));
fid_old = fopen(ini_file_old,'rt');
ini_old = read_ini_file(fid_old,2023);
toc;
tic;
fprintf('Reading New File')
ini_file_new=fullfile(db_pth_root,'Calculation_Procedures\TraceAnalysis_ini\',SiteID,sprintf('%s_%sStage.ini',SiteID,Stage));
fid_new = fopen(ini_file_new,'rt');
ini_new = read_ini_file_update(fid_new,2023);
toc;
ini_new = rmfield(ini_new,'Last_Updated');
ini_old = rmfield(ini_old,'Last_Updated');
eq = isequal(ini_old,ini_new);
if eq >0
    fprintf('\nIni files are equivalent')
else
    bad_matches = 0;
    for j = 1:length(ini_old)
        old = ini_old(j);
        new = ini_new(j);
        if ~isequal(old,new)
            fprintf('\n\nInequivalence in %s, which is item %i',old.variableName, j)
            old_fields = fieldnames(old);
            new_fields = fieldnames(new);
            if ~isequal(old_fields,new_fields)
                fprintf('\nfields do not match')
            else
                for k = 1:length(old_fields)
                    old_val = getfield(old,char(old_fields(k)));
                    new_val = getfield(new,char(new_fields(k)));
                    if ~isequal(old_val,new_val)
                        fprintf('\nThe values do not match in the %s field',char(old_fields(k)))
                        if isstruct(old_val)
                            of = fieldnames(old_val);
                            nf = fieldnames(new_val);
                            if ~isequal(of,nf)
                                fprintf('\nThe fieldnames do not match')
                            else
                                for i=1:length(of)
                                    o = getfield(old_val,char(of(i)));
                                    n = getfield(new_val,char(nf(i)));
                                    if ~isequal(o,n)
                                        fprintf('\nCheck the value in field %s',char(of(i)))
                                        fprintf('\nThe old value is:')
                                        disp(o)%,new_val)
                                        fprintf('\nThe new value is:')
                                        disp(n)
                                        
                                    end
                                end
                            end

                        else
                            fprintf('\nThe old value is:')
                            disp(old_val)%,new_val)
                            fprintf('\nThe new value is:')
                            disp(new_val)
                        end
                    end
                end
            end
        end

    end
end
fprintf('\n\n')