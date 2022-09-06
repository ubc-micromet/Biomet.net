SiteFlag = 'CR';

startDate.year  = 1998;
startDate.month = 3; 
startDate.day   = 9;
startDate.hour  = 0; 
startDate.minute= 30;
startDate.num   = datenum(startDate.year,startDate.month,startDate.day, ...
                            startDate.hour, startDate.minute,0);
                        
endDate.year    = 1998;
endDate.month   = 3;
endDate.day     = 9;
endDate.hour    = 24;
endDate.minute  = 0;
endDate.num     = datenum(endDate.year,endDate.month,endDate.day, ...
                            endDate.hour, endDate.minute,0);

stats = fr_calc_main(SiteFlag,startDate,endDate);