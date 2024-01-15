function [day,Mean,Std,Median,Max,Min,Count] = Daily_Resample(x,TV);
    % Since clean_tv starts at 00:30 instead of 00:00 each year 
    rnd = TV(1)-floor(TV(1));
    G = findgroups(floor(TV-rnd));
    day = splitapply(@mean,floor(TV-rnd),G);
    Mean = splitapply(@(y)mean(y,'omitnan'),x,G);
    Std = splitapply(@(y)std(y,'omitnan'),x,G);
    Median = splitapply(@(y)median(y,'omitnan'),x,G);
    Max = splitapply(@max,x,G);
    Min = splitapply(@min,x,G);
    Count = splitapply(@sum,isfinite(x),G);
end