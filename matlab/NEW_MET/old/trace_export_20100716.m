function [export_mat] = trace_export(file_opts,trc,export_mat)
% [export] = trace_export(file_opts,trc)
%
% Export the trace trc according to the information given in file_opts.
% If text export is extracted, the data are just added as an addional column
% of the matrix export_mat. Text export then has to be completed elsewhere.
%
%	kai* 	Created:			14 Dec, 2000
%			Last Modified: 14 Dec, 2000

% In first stage cleaning file_opts contains a .days field.
% Create this if it is not present.
% BEWARE! The export using days does not work for export to the database (because
% the database should always contain full years) and for the export of the trace
% structure, since various fields in the structure would have to be truncated and
% really, I couldn't be bothered.

if file_opts.out_path(end) ~= filesep
    file_opts.out_path = [file_opts.out_path filesep];
end

if ~isfield(file_opts,'days')
   Year = trc.Year;
   NumDays =  datenum(Year+1,1,1) - datenum(Year,1,1) + 1;
   file_opts.days = [1 NumDays];	%full GMT year
end

% If export is to database, always export complete trace and ignore days given
if strcmp(lower(file_opts.out_path), 'database')
    export_data = trc.data;
    clean_tv    = trc.timeVector;
else
    % kai* June 12, 2001
    % Inserted >= instead of > so that first measurement can be taken in
    ind_tv     = find(trc.DOY <= file_opts.days(2)+1 & trc.DOY >= file_opts.days(1));
    export_data = NaN .* zeros(size(trc.timeVector));
    if ~isempty(trc.data)
       export_data(ind_tv) = trc.data(ind_tv);
    end
    clean_tv            = trc.timeVector;
    
    % kai* May 30, 2001
    % inserted this path specification to separate flux and climate data 
    % in the output. Before the output went to file_opts.out_path
    % dgg Feb 26, 2002
    % Added chamber file path
    if strcmp(file_opts.format,'bnc')
		 if ~isfield(trc,'stage')
			trc.stage = 'first';
        end

       switch upper(trc.stage)
       case 'FIRST'
          switch upper(trc.ini.measurementType)
          case {'CL' 'BERMS'}
             path = [file_opts.out_path 'climate\clean\'];
          case 'FL'
             path = [file_opts.out_path 'flux\clean\'];
          case 'PR'
             path = [file_opts.out_path 'profile\clean\'];
          case 'CH'
             path = [file_opts.out_path 'chambers\clean\'];
          otherwise
             path = [file_opts.out_path '\' trc.ini.measurementType '\clean\'];
          end
       otherwise
          path = [file_opts.out_path];
       end
    elseif strcmp(file_opts.format,'bnr')
       switch upper(trc.ini.measurementType)
        case 'CL'
            path = [file_opts.out_path 'climate\'];
        case 'FL'
            path = [file_opts.out_path 'flux\'];
        case 'PR'
            path = [file_opts.out_path 'profile\'];
        case 'CH'
            path = [file_opts.out_path 'chambers\clean\'];
        otherwise
            path = [file_opts.out_path];
        end
    end    
end

% If export is to database, always export complete trace and ignore days given 
if ~strcmp(lower(file_opts.out_path), 'database')
   if isfield(trc,'data') & ~isempty(trc.data)
       switch file_opts.format
       case 'txt'
           % Add column without saving
           export_mat = [export_mat export_data];
       case 'mat'
           % Save structure under the variable name - data is not truncated to days
           eval([trc.variableName ' = trc;']);
           if length(trc.variableName) >= 32
               save([file_opts.out_path trc.variableName],[trc.variableName(1:31) '*']);
           else
               save([file_opts.out_path trc.variableName],trc.variableName);
           end
       case 'mtc'
           % Save data under the variable name
           eval([trc.variableName ' = export_data;']);
           if length(trc.variableName) >= 32
               save([file_opts.out_path trc.variableName],[trc.variableName(1:31) '*']);
           else
               save([file_opts.out_path trc.variableName],trc.variableName);
           end
           % Save the time vector with it
           save([file_opts.out_path 'clean_tv'],'clean_tv');
       case 'bnc' 
           % Here there is no raw data, so just save cleaned
           save_bor([path trc.variableName],1,export_data);
           save_bor([path 'clean_tv'],8,clean_tv);
       case 'bnr'
           if isfield(trc,'data_old')
               save_bor([path  trc.variableName],1,trc.data_old(ind_tv));
               save_bor([path 'clean_tv'],8,clean_tv(ind_tv));
           else
               disp(['No uncleaned data can be output for trace ' trc.variableName]);
           end
       end
   end            
else          
    err = save_clean(trc);
    if err==0
        disp(['Could not save ' cln.variableName ' into the database!']);
    end      
end         


