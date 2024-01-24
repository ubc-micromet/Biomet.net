function [data_out,Flag]=SpikeFilter(data_in,tv_in,order,thresh,thresh_type,window)
    % This function filters outliers using a z-scorealized moving window
    % It filters the data by deviation from mean, slope (first derivative), and curvature (second derivative), etc.
    
    % Parameters:
    % data_in - the trace to be filtered
    % tv_in - the time vector of the trace to be filtered
    % order - order of derivatives to be calculated; 0 (raw data, i.e., no derivative), 1,2, ... are 1st, 2nd, etc.
    % thresh - threhold for filtering of length 1 (symmetrical) or 2 (asymmetrical) - given as either a z-score or natural units
    % thresh_type - "z-score" or "natural"
    %   "z-score" - filters out by z-score using either the full dataset or a moving window
    %   "natural" - filters by natural usings - makes most sense in the context of a first derivative
    %             - e.g., if working with Water Table Height thresh = [-0.5,2] would apply an asymmetric filter removing drops < 0.5 cm/half-hour or jumps > 2 cm/half-hour
    % window - optional rolling window if thresh_type is "z-score" over which to apply the filter (defaults to 0, i.e., no moving window)

    arg_default('order',0);
    arg_default('thresh',3);
    arg_default('thresh_type','z-score');
    arg_default('window',0);
    
    Collapsed = isnan(data_in);
    dropped = zeros(length(order),1);
    Keep = logical(ones(length(data_in),length(order)));
    Drop = logical(zeros(length(data_in),length(order)));
    Keep(Collapsed,1:end)=0;

    j = [0];
    k = [0];
    for i=1:length(order)
        d = order(i);
        ix = Keep(:,i);
        if d > 0
            y = [NaN(ceil(d/2),1); diff(data_in(ix),d); NaN(floor(d/2),1)];
        else
            y = data_in(ix);
        end

        if strcmp(thresh_type,"natural")
            flag = NatualFilter(y,thresh);
        else
            flag = ZFilter(y,tv_in(ix),thresh,window);
        end

        
        Keep(ix,i) = flag;
        Drop(ix,i) = ~flag;
    end
    Flag = min(Drop,[],2);
    data_out = data_in;
    data_out(Flag)=NaN;
end

function flag=ZFilter(y,tv,thresh,window)
    if window == 0
        u = mean(y,'omitnan');
        s = std(y,'omitnan');
    else
        u = movmean(y,window,'omitnan','SamplePoints',tv);
        s = movstd(y,window,'omitnan','SamplePoints',tv);
    end
    z_norm = (y-u)./s;
    if length(thresh)>1
        z_range = [thresh(1),thresh(end)];
    else
        z_range = [-thresh,thresh];
    end
    flag = and(z_norm>z_range(1),z_norm<z_range(2));

end

function flag=NatualFilter(y,thresh)
    if length(thresh)>1
        range = [thresh(1),thresh(end)];
    else
        range = [-thresh,thresh];
    end
    flag = and(y>range(1),y<range(2));
end
