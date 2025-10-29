#!/bin/sh
set -e

# Wait for PostgreSQL to be ready
python - <<'PY'
import os
import sys
import time
import psycopg2
from psycopg2 import OperationalError

host = os.getenv('POSTGRES_HOST', 'db')
port = int(os.getenv('POSTGRES_PORT', '5432'))
user = os.getenv('POSTGRES_USER', 'postgres')
password = os.getenv('POSTGRES_PASSWORD', '')
dbname = os.getenv('POSTGRES_DB', 'postgres')

for attempt in range(60):
    try:
        conn = psycopg2.connect(host=host, port=port, user=user, password=password, dbname=dbname)
        conn.close()
        break
    except OperationalError:
        time.sleep(1)
else:
    print('Database is not ready after waiting. Exiting.', file=sys.stderr)
    sys.exit(1)
PY

python manage.py migrate --noinput
python manage.py runserver 0.0.0.0:8000


