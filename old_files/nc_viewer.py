import netCDF4 as nc
import numpy as np
import os
from pprint import pprint

def flatten_list(matrix):
    flat_list = []
    for row in matrix:
        flat_list += row
    
    return flat_list

folder = "downloaded_files/"
nc_files = [folder + file for file in os.listdir(folder)]

read_files = [nc.Dataset(fn) for fn in nc_files]

pprint(read_files[0].variables.keys())

flare_class = [file.variables['flare_class'][:].tolist() for file in read_files]
flare_status = [file.variables['status'][:].tolist() for file in read_files]
flare_times = [file.variables['time'][:].tolist() for file in read_files]

flares = zip(flatten_list(flare_class), flatten_list(flare_status))
flares = list(flares)

pprint(flares)


flare_status = np.array(flatten_list(flare_status))
pprint(flare_status[flare_status == "EVENT_START"])

flare_times = np.array(flatten_list(flare_times))
pprint(flare_times[flare_status == "EVENT_START"])

# print(read_files[0].variables['status'][:])


# pprint(flatten_list(flare_times))

# for index, i in enumerate(flares):
#     # print(index, i)
#     print(i[1], i[1] == 'EVENT_PEAK')
#     if i[1] == 'EVENT_PEAK':
#         # print(f"popping {i}")
#         flares.pop(index)
#     print(i[1], i[1] == 'EVENT_PEAK')
#     print()


# a = [1, 2, 3, 2, 2, 4, 3, 6, 2]

# for index, i in enumerate(a):
    