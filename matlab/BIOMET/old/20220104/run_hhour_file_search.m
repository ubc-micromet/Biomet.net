function run_hhour_file_search(sites,years,mail);

if isempty(sites)
  sites = { 'CR' 'YF' 'OY' 'BS' 'PA' 'HJP02' };
end

if isempty(years)
  dv_now = datevec(now);
  years = dv_now(1);
end

% run check for all sites
delete biomet_missing_hhour_report.log;
 for i=1:length(years)
     for j=1:length(sites)
        fr_find_missing_hhour_files(char(sites{j}),years(i));
    end
end
     
if mail
  % mail results log to db admin and techs
   setpref('Internet','SMTP_Server','smtp.interchange.ubc.ca');
   setpref('Internet','E_mail','nick.grant@ubc.ca');
   %lst_to = {'nick.grant@ubc.ca' 'dominic.lessard@ubc.ca' 'zoran.nesic@ubc.ca'  };
   lst_to = {'nick.grant@ubc.ca' }; %'dominic.lessard@ubc.ca' 'zoran.nesic@ubc.ca'  };
   flog = {'biomet_missing_hhour_report.log'};
   sendmail(lst_to,'monthly hhour file search results','Use PFE to open attachment',flog)
end