function [data_out] = logger_register(data_in,table_ID);

data_out = [];

if data_in == table_ID
data_out = 1;
elseif data_in ~=table_ID
    data_out = 0
end

