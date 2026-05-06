#!/bin/bash

REMOVE_VOLUMES=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean|-c) REMOVE_VOLUMES=true; shift ;;
        --help|-h)
            echo "Usage: ./stop.sh [--clean|-c]"
            echo "  --clean   stop services and drop all volumes (deletes DB data)"
            exit 0 ;;
        *)
            echo "Unknown option: $1"
            exit 1 ;;
    esac
done

if [ "$REMOVE_VOLUMES" = true ]; then
    read -p "This will delete all database data. Are you sure? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    docker compose down -v
    echo "Services stopped, volumes removed."
else
    docker compose down
    echo "Services stopped (data preserved). Use --clean to drop volumes."
fi
