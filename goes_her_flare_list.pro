; Full outer join of the HEK and GOES flare lists

function goes_her_flare_list, gev, her

    ; Sample data arrays
    ; employee_data = [{employee_id: 1, name: 'John'}, {employee_id: 2, name: 'Alice'}, {employee_id: 3, name: 'Bob'}]
    ; salary_data = [{employee_id: 1, salary: 50000}, {employee_id: 3, salary: 60000}]

    ; Initialize an array to store the result of the join
    result_data = []

    ; Perform the join
    for i = 0, (n_elements(employee_data) - 1) do begin

        employee = employee_data[i]
        salary = where(salary_data.employee_id eq employee.employee_id)

        if n_elements(salary) GT 0 then begin

            joined_data = {employee_id: employee.employee_id, name: employee.name, salary: salary_data[salary[0]].salary}
            result_data = [result_data, joined_data]

        endif

    endfor

    ; Print the result
    print, result_data


end