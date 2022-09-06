Recalc setup:

- Create directory BASEDIR\recalc_YYYYMMDD
- Create directory BASEDIR\recalc_YYYYMMDD\hhour
- Copy \\paoa001\sites\SITEID\hhour\calibrations* to 
  BASEDIR\recalc_YYYYMMDD\hhour

- Create directoy BASEDIR\recalc_YYYYMMDD\site_specific
- Copy \\paoa001\sites\SITEID\Site_specific\*.m to 
  BASEDIR\recalc_YYYYMMDD\site_specific
- Copy d:\kai\matlab\recalc\fr_get_local_path.m to
  BASEDIR\recalc_YYYYMMDD\site_specific

- Create directoy BASEDIR\recalc_YYYYMMDD\PC_specific
- Copy d:\kai\matlab\recalc\fr_get_pc_name.m to
  BASEDIR\recalc_YYYYMMDD\PC_specific

- Create directoy BASEDIR\recalc_YYYYMMDD\biomet.net\matlab
- Copy \\paoa001\matlab to 
  BASEDIR\recalc_YYYYMMDD\biomet.net\matlab

- Copy required part of \\annex001\database to
  BASEDIR\recalc_YYYYMMDD\database

- Copy d:\kai\matlab\recalc\recalc_set_path.m to
  BASEDIR\recalc_YYYYMMDD

- Startup matlab
- cd to BASEDIR\recalc_YYYYMMDD
- run recalc_set_path.m
- run recalc_siteyear(SiteID,tv_recalc)


