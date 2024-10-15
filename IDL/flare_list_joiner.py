import pandas as pd
from pandas import DataFrame
import sys

def goes_class_ranking_val(goes_class: str) -> float:

    class_rank = {
        "A": 10,
        "B": 20,
        "C": 30,
        "M": 40,
        "X": 50
    }
    
    if not isinstance(goes_class, str):
        return 0
    
    letter = goes_class[0]
    number = goes_class[1:]

    return class_rank[letter] + float(number)

def goes_class_ranking_val_decode(goes_class_val: str) -> float:

    class_rank = {
        "A": 10,
        "B": 20,
        "C": 30,
        "M": 40,
        "X": 50
    }
    
    goes_rank = ""

    for rank in class_rank:
        if goes_class_val - class_rank[rank] > 0:
            goes_rank = rank
        else:
            break

    return f"{goes_rank}{round(goes_class_val - class_rank[goes_rank], 1)}"


def create_her_goes_list(
            her: DataFrame,
            gev: DataFrame,
            csv_out=False
        ) -> DataFrame:

    her = her.rename(columns={
        "GEV_START": "flare_start",
        "GEV_PEAK": "flare_peak",
        "GEV_END": "flare_end",
        "GOES_CLASS": "class",
        "AIA_LOC": "aia_loc",
        "AIA_XCEN": "aia_xcen",
        "AIA_YCEN": "aia_ycen"
    })

    gev = gev.rename(columns={
        "GSTART": "flare_start",
        "GPEAK": "flare_peak",
        "GEND": "flare_end",
        "CLASS": "class",
        "LOC": "loc",
        "NOAA_AR": "noaa_ar"
    })

    fl_zip = zip(
        [her, gev],
        ["%Y-%m-%dT%H:%M:%S", "%d-%b-%Y %H:%M:%S"]
    )

    for fl, fl_fmt in fl_zip:
        for col in ["flare_start", "flare_peak", "flare_end"]:
            fl[col] = pd.to_datetime(fl[col], format=fl_fmt)

    result =  (
        her
            .merge(gev, on=["flare_peak"], how='outer')
            .sort_values(by=["flare_peak"])
            .reset_index()
    )

    merged_flare_start = pd.concat(
        [result['flare_start_x'], result['flare_start_y']],
        axis=1
    )

    merged_flare_end = pd.concat(
        [result['flare_end_x'], result['flare_end_y']],
        axis=1
    )

    merged_class = pd.concat(
        [
            result['class_x'].apply(goes_class_ranking_val), 
            result['class_y'].apply(goes_class_ranking_val)
        ],
        axis=1
    )

    result['flare_start'] = merged_flare_start.min(axis=1)
    result['flare_end'] = merged_flare_end.max(axis=1)
    result['class'] = (
        merged_class
            .max(axis=1)
            .apply(goes_class_ranking_val_decode)
    )

    result = result.drop(
        ['flare_start_x',
         'flare_start_y',
         'flare_end_x',
         'flare_end_y',
         'class_x',
         'class_y',
         'index'],
        axis=1
    )

    return (
        result[[
            'flare_start',
            'flare_peak',
            'flare_end',
            'class',
            'aia_loc',
            'aia_xcen',
            'aia_ycen',
            'loc',
            'noaa_ar'
        ]]
    )


if __name__ == "__main__":

    her_filepath = sys.argv[1]
    gev_filepath = sys.argv[2]

    her_filename = her_filepath.rsplit('/', 1)[-1]
    gev_filename = gev_filepath.rsplit('/', 1)[-1]

    result_filename = f"joined_{her_filename[:-4]}+{gev_filename}"
    output_filepath = f"flare_lists_csv/{result_filename}"

    try:
        verbose = sys.argv[3]
        if verbose == 'verbose':
            verbose = True
    except:
        verbose = False

    if verbose:
        print(f"HER filepath: {her_filepath}")
        print(f"GEV filepath: {gev_filepath}")
        print(f"Output filepath: {output_filepath}")

    her = pd.read_csv(her_filepath)

    if verbose:
        print("HER list loaded.")

    gev = pd.read_csv(gev_filepath)

    if verbose:
        print("HER list loaded.")

    if verbose:
        print("Joining lists...")

    result = create_her_goes_list(her, gev)
    result.to_csv(output_filepath)

    if verbose:
        print(f"Joined and output to {output_filepath}")
