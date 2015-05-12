select trim(regexp_replace(regexp_replace(body, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g'))
from entities;
