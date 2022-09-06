function sortCalFileFields(fileName)

load (fileName)
save([fileName '_' datestr(now,30)]);
fieldOrder = {'TimeVector','SerNum','measured','HF_data','corrected','Ignore'};

for cField = fieldOrder
    ccField = char(cField);
    c(1).(ccField) = 0;
end

for i=1:length(cal_values)
    for cField = fieldOrder
        ccField = char(cField);
        if isfield(cal_values,ccField)
            c(i).(ccField) = cal_values(i).(ccField);
        elseif strcmp(ccField,'Ignore')
            c(i).(ccField) = 0;
        end
    end
end
cal_values = c;
save(fileName,'cal_values')
