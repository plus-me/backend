#!/bin/bash

cd /app || exit

if [ $# -eq 0 ]; then
    echo "Usage: start.sh [PROCESS_TYPE](server/beat/worker/flower)"
    exit 1
fi

PROCESS_TYPE=$1

if [ "$PROCESS_TYPE" = "server" ]; then
    gunicorn \
        --bind 0.0.0.0:8000 \
        --workers 2 \
        --worker-class sync \
        --log-level DEBUG \
        --capture-output \
        --error-logfile "-" \
            wepublic_backend.wsgi
elif [ "$PROCESS_TYPE" = "beat" ]; then
    celery \
        --app wepublic_backend.celery_app \
        beat \
        --loglevel INFO \
        --scheduler django_celery_beat.schedulers:DatabaseScheduler
elif [ "$PROCESS_TYPE" = "flower" ]; then
    celery \
        --app wepublic_backend.celery_app \
        flower \
        --basic_auth="${CELERY_FLOWER_USER}:${CELERY_FLOWER_PASSWORD}" \
        --loglevel INFO
elif [ "$PROCESS_TYPE" = "worker" ]; then
    celery \
        --app wepublic_backend.celery_app \
        worker \
        --loglevel INFO
fi
