# Solar Flare Finder
A collection of IDL scripts to create a database of solar flares with Boolean columns for observations made by the following instruments:
![instrument_info](https://github.com/james-kc/solar_flare_finder/assets/78704331/13d1d469-86dd-474f-bdf9-464d3e958cf7)

* Boolean "observed" columns (e.g. RSI_OBSERVED) are 1 for flares where the instrument made at least one measurement between the GOES start and end times.
* "Fraction observed" columns (e.g. RSI_FRAC_OBS) return the fraction of the total flare time (time delta between GOES start and end times) observed by the instrument.
* "Fraction observed rise" columns (e.g. RSI_FRAC_OBS_RISE) return the fraction of the flare "rise" time (time delta between GOES start and peak times) observed by the instrument.
* "Fraction observed fall" columns (e.g. RSI_FRAC_OBS_FALL) return the fraction of the flare "fall" time (time delta between GOES peak and end times) observed by the instrument.
* RSI_FLARE_TRIGGERED is a Boolean column representing whether RHESSI flagged any of its observations as having seen a flare. This was included to investigate RHESSI flare flag inaccuracies (See the following appendix:   [APPENDIX - RHESSI Flare Flag Inaccuracies.pdf](https://github.com/james-kc/solar_flare_finder/files/15418652/APPENDIX.-.RHESSI.Flare.Flag.Inaccuracies.pdf))

## Existing Data
[instr_observed_flare_list.csv](https://github.com/james-kc/solar_flare_finder/blob/main/instr_observed_flare_list.csv) contains the above information for the time range 2010-04-13 to 2019-05-30.

## Running the Code
It is planned that this project will be moved to Python using SunPy which will improve accessibility. For those who are prepared to venture into the unknown, this is where you should start:
1. Run [generate_flare_list.pro](https://github.com/james-kc/solar_flare_finder/blob/main/generate_flare_list.pro) in the following form: `generate_flare_list, '2023-10-01', '2023-10-02'`.
2. Edit [line 30 compile_obs_table.pro](https://github.com/james-kc/solar_flare_finder/blob/ce49ecdae793924d7d5250704eff92022c503e61/compile_obs_table.pro#L30C32-L30C108) to point to the flare list generated in step 1 (e.g. `flare_lists_csv/joined_her_2010-4-10_2019-5-31+gev_2010-04-11_2019-06-01.csv`).
3. Run [compile_obs_table.pro](https://github.com/james-kc/solar_flare_finder/blob/main/compile_obs_table.pro) with the following command `compile_obs_table`.

## MSci Thesis
[Statistics of Multi-Instrument Observations of Solar Flares](https://github.com/james-kc/solar_flare_finder/blob/main/Statistics%20of%20Multi-Instrument%20Observations%20of%20Solar%20Flares%20-%20James%20Kavanagh-Cranston.pdf)

## Ongoing Python Conversion Work
Work being completed in the conversion of this project to python can be found in the [python-conversion](https://github.com/james-kc/solar_flare_finder/tree/python-conversion) branch of this repository.

