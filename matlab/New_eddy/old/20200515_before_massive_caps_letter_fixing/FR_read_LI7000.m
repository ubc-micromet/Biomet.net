function [EngUnits,Header] = fr_read_LI7000(dateIn,configIn,instrumentNum)

[EngUnits,Header] = fr_read_digital2(dateIn,configIn,instrumentNum);

EngUnits = resample(EngUnits,36000,length(EngUnits),100);