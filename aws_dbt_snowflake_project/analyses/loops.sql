{% set cols = ['BOOKING_ID', 'NIGHTS_BOOKED', 'BOOKING_AMOUNT'] %}
select
{% for col in cols %}
   {{col}}
    {% if not loop.last %},{% endif %}
{% endfor %}
from {{ref('bronze_bookings')}} 