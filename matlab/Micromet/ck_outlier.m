function ck_all=ck_outlier(siteID,var_name,var_type,sp_date,wlen,thres,tsc_flag)
% siteID   [chr]: site name.       e.g. 'DSM'
% var_name [chr]: variable name.   e.g. 'MET_HMP_T_2m_Avg'
% var_type [chr]: MET(CR1000 data) or Flux(EC data).
% sp_date  [num/cell]: the specified date(s). 
% wlen     [int]: length of computation window. This number should be even.
%                 e.g. 12 → 6 points before and after the specified time.
% thres    [int]: threshold.
%                 e.g. 4 → data fall outside 4 std will be rejected.
% tsc_flag [int]: 1(need time shift correction). 
%                 For smartflux 30-minute lag correction. (fixed at 2021-Nov-11 09:30 am)

% siteID='DSM';var_name='MET_HMP_T_2m_Avg';var_type='MET';
% sp_date={datenum(2021,9,3,8,30,0);datenum(2021,9,3,9,0,0)};
% thres=4;tsc_flag=0; wlen=12;

% ck_all=ck_outlier(siteID,var_name,var_type,sp_date,12,thres,tsc_flag)
% ck_all_2=ck_outlier(siteID,var_name,var_type,sp_date,16,thres,tsc_flag)
% ck_all_3=ck_outlier(siteID,var_name,var_type,sp_date,24,thres,tsc_flag)

  %% Define path, current time, and date range
    pth = biomet_path('yyyy',siteID);

    
    % Current time & year
    c = clock;
    Year_now = c(1);
    
    % Define date range (i.e. years of interest)
    switch siteID
        case 'BB'
            Years = 2014:Year_now;
        case 'BB2'
            Years = 2019:Year_now;
		case 'DSM'
            Years = 2021:Year_now;
        otherwise
            error('Wrong site name!')
    end
    
    
    % Load time vector
    var = 'clean_tv';
	if strcmp(siteID,'DSM')
        tv=read_bor(fullfile(pth,'Flux',var),8,[],Years);
    else
        tv=read_bor(fullfile(pth,'MET',var),8,[],Years);
    end
    
	
    
    % Define start and end indices for web plots
    inde = find(datetime(datestr(tv)) == dateshift(datetime(c),'start','hour'));
    formatOut = 'yyyy-mm-dd HH:MM:SS';
    tv_export = datestr(tv,formatOut);
    
    % parameters for "Running Standard Deviation"
    ck_all=table;

    
  %%  Load data
    
    varStruct.name = var_name;
    varStruct.type = var_type;
    data = load_data(varStruct,pth,Years);
   
    
    % Time Shift Correction (fixed at 2021-Nov-11 09:30 am)  
    if tsc_flag==1
        tsc=find(tv<=datenum(2021,11,11,09,30,0));  
        data=data(tsc(2:end),1);
    end
    
    data = data(1:inde,:);

  %% Start computing
  
  if iscell(sp_date)
      for j=1:size(sp_date,1)
          % find position
          p=find(tv==sp_date{j});
          
          % extract data
          g=data([p-wlen/2:p-1,p+1:p+wlen/2],1);
          target=data(p,1);
          
          % compute std and mean
          g_std=nanstd(g);
          g_avg=nanmean(g);
          g_low=g_avg-thres*g_std;
          g_up=g_avg+thres*g_std;
          
          % save results in a table variable
          fprintf(1,'%d\n',j)
          fprintf(1,'%s\n',tv_export(p,:))
          timestamp=string(tv_export(p,:));
          Gval={data([p-wlen/2:p+wlen/2],1)};
          UpperBound=g_up;
          LowerBound=g_low;
          if target>g_up || target<g_low, Rejected=1; else, Rejected=0; end
          
          ck_all(j,:)=table(string(var_name),timestamp,target,Gval,LowerBound,UpperBound,g_std,g_avg,thres,wlen,Rejected);
          ck_all.Properties.VariableNames={'VarName','timestamp','value','group_value',...
              'LowerBound','UpperBound','std','avg','Threshold','Window_len','RJ_flag'};
      end
  else
      p=find(tv==sp_date);% find position
      g=data([p-wlen/2:p-1,p+1:p+wlen/2],1);% extract data
      target=data(p,1);
      g_std=std(g); g_avg=nanmean(g); % compute std and mean
      g_low=g_avg-thres*g_std; g_up=g_avg+thres*g_std;
      
      % save results in a table variable      
      timestamp=string(tv_export(p,:));      
      Gval={data([p-wlen/2:p+wlen/2],1)};
      UpperBound=g_up; LowerBound=g_low;
      if target>g_up || target<g_low, Rejected=1; else, Rejected=0; end
      
      ck_all=table(string(var_name),timestamp,target,Gval,LowerBound,UpperBound,g_std,g_avg,thres,wlen,Rejected);
      ck_all.Properties.VariableNames={'VarName','timestamp','value','group_value',...
              'LowerBound','UpperBound','std','avg','Threshold','Window_len','RJ_flag'};
  end
  

end

