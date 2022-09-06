For each year, there are: 
24h totals (eg. 1997_24h_totals) 
24h means
24h max
24h min
Daytime totals (selected when solar radiation > 10 W/m2)
Daytime means (selected when solar radiation > 10 W/m2)

The daily periods were selected after converting GMT to PST without a daylight savings offset in the summer.

The order of the variables in each file are:
Column 1: Year
Column 2: DOY (day of year)
Column 3: shortwave downwelling radiation at 45 m (W/m2 for means, MJ/m2 for totals)
Column 4: net radiation at 40 m (W/m2 for means, MJ/m2 for totals)
Column 5: air temperature at 40 m (deg C for means and totals)
Column 6: relative humidity at 40 m (% for means and totals)
Column 7: soil heat flux corrected for storage in top 3 cm (W/m2 for means, MJ/m2 for totals)
Column 8: precipitation (mm/30 min for means, mm for totals)

Exception:
The 24h max and min files have only,
Column 1: Year
Column 2: DOY (day of year)
Column 5: air temperature at 40 m (deg C)


Note that if a number is NaN, then there isn't an entry for that day.
