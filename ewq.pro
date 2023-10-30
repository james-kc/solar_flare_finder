pro ewq

    joined_csv_filename = 'flare_lists_csv/testing_csv.csv'

    joined_flare_list = read_csv(joined_csv_filename, header=header)

    print, header

    help, joined_flare_list

    print, tag_names(joined_flare_list)

end