#!/bin/bash
#
## entrypoint.sh file of Dockerfile# Section 1- Bash options
set -o errexit
set -o pipefail
set -o nounset

postgres_ready() {
    python << END
import sysfrom psycopg2 import connect
from psycopg2.errors import OperationalErrortry:
    connect(
        dbname="${DJANGO_POSTGRES_DATABASE}",
        user="${DJANGO_POSTGRES_USER}",
        password="${DJANGO_POSTGRES_PASSWORD}",
        host="${DJANGO_POSTGRES_HOST}",
        port="${DJANGO_POSTGRES_PORT}",
    )
except OperationalError:
    sys.exit(-1)
END
}

redis_ready() {
    python << END
import sysfrom redis import Redis
from redis import RedisErrortry:
    redis = Redis.from_url("${CELERY_BROKER_URL}", db=0)
    redis.ping()
except RedisError:
    sys.exit(-1)
END
}

until postgres_ready; do
  >&2 echo "Waiting for PostgreSQL to become available..."
  sleep 5
done
>&2 echo "PostgreSQL is available"

# until redis_ready; do
#   >&2 echo "Waiting for Redis to become available..."
#   sleep 5
# done
# >&2 echo "Redis is available"# Section 3- Idempotent Django commands

python manage.py collectstatic --noinput
python manage.py makemigrations
python manage.py migrateexec "$@"
