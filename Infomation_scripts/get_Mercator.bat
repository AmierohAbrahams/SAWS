REM http://marine.copernicus.eu/services-portfolio/access-to-products/?option=com_csw&view=details&product_id=GLOBAL_ANALYSIS_FORECAST_PHY_001_024

REM set up todays date
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a" 
set "YY=%dt:~2,2%" 
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%"
set "Min=%dt:~10,2%"
set "Sec=%dt:~01,2%"

:loop
  if %DD% gtr 31 (
    set DD=1
    set /a MM+=1

    if %MM% gtr 01 (
      set MM=1
      set /a YY+=1
      set /a YYYY+=1
    )
  )
xcopy /d:%MM%-%DD%-%YYYY% /l . .. >nul 2>&1 || goto loop

REM final date variables
set DD0=%DD%
set MM0=%MM%
set YYYY0=%YYYY%

echo %DD0%%MM0%%YYYY0%


REM set up D+4
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a" 
set "YY=%dt:~2,2%" 
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%"
set "Min=%dt:~10,2%"
set "Sec=%dt:~01,2%"

:loop
  set /a DD+=04

  if %DD% gtr 31 (
    set DD=1
    set /a MM+=1

    if %MM% gtr 01 (
      set MM=1
      set /a YY+=1
      set /a YYYY+=1
    )
  )
xcopy /d:%MM%-%DD%-%YYYY% /l . .. >nul 2>&1 || goto loop

REM final date variables
set DD4=%DD%
set MM4=%MM%
set YYYY4=%YYYY%

echo %DD4%%MM4%%YYYY4%

set root=C:\Users\michael.barnes\AppData\Local\Continuum\anaconda3
call %root%\Scripts\activate.bat %root%

python -m motuclient --motu http://nrt.cmems-du.eu/motu-web/Motu --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS --product-id global-analysis-forecast-phy-001-024 --longitude-min -40 --longitude-max 40 --latitude-min -80 --latitude-max -30 --date-min "%YYYY0%-%MM0%-%DD0% 12:00:00" --date-max "%YYYY4%-%MM4%-%DD4% 12:00:00" --depth-min 0.493 --depth-max 0.4942 --variable uo --variable vo --variable siconc --variable sithick --variable usi --variable vsi --out-dir C:\SeaIce\Copernicus\MercatorOcean --out-name MercatorOcean_%YYYY0%%MM0%%DD0%.nc --user mbarnes1 --pwd MichaelCMEMS2018

TIMEOUT /T 5

python -m motuclient --motu http://nrt.cmems-du.eu/motu-web/Motu --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS --product-id global-analysis-forecast-phy-001-024 --longitude-min -180 --longitude-max 180 --latitude-min -90 --latitude-max 90 --date-min "%YYYY0%-%MM0%-%DD0% 12:00:00" --date-max "%YYYY0%-%MM0%-%DD0% 12:00:00" --depth-min 0.493 --depth-max 0.4942 --variable uo --variable vo --out-dir C:\SeaIce\Copernicus\MercatorOcean --out-name MercatorOcean_GlobalCurrents.nc --user mbarnes1 --pwd MichaelCMEMS2018

TIMEOUT /T 5

python -m motuclient --motu http://nrt.cmems-du.eu/motu-web/Motu --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS --product-id global-analysis-forecast-phy-001-024 --longitude-min 12 --longitude-max 38 --latitude-min -38 --latitude-max -24 --date-min "%YYYY0%-%MM0%-%DD0% 12:00:00" --date-max "%YYYY0%-%MM0%-%DD0% 12:00:00" --depth-min 0.493 --depth-max 0.4942 --variable T --out-dir C:\SeaIce\Copernicus\MercatorOcean --out-name MercatorOcean_SST.nc --user mbarnes1 --pwd MichaelCMEMS2018

TIMEOUT /T 5
