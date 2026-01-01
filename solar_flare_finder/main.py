import sunpy
from sunpy.net import Fido, attrs as a

start_date = '2013-11-09'
end_date = '2013-11-08'

hek_result = Fido.search(
    a.Time(start_date, end_date),
    a.hek.EventType('FL'),
    a.hek.FL.GOESCls > 'C2.5'
)

print(hek_result)

