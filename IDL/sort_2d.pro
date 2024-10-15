function sort_2d, data

    sortIndex = Sort( data[0,*] )

    for j = 0, 1 do data[j, *] = data[j, sortIndex]

    return, data

end