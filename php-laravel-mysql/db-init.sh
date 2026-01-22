#!/bin/bash
set -e

# Funzione per attendere che il database sia pronto
wait_for_db() {
    echo "Waiting for database to be ready..."
    until php artisan db:show &>/dev/null; do
        echo "Database is unavailable - sleeping"
        sleep 2
    done
    echo "Database is up - continuing"
}
check_db() {
    echo "Checking DB Connection..."

    if php artisan db:show &>/dev/null; then
        echo "Database is up!"
    else
        echo "Database is down!"
    fi
}

# Attendi che il database sia pronto

# Ottimizza per produzione
if [ "$APP_ENV" != "production" ]; then
    wait_for_db
else
    check_db
fi

# Esegui le migrazioni
echo "Running migrations..."
php artisan migrate --force -n || echo "Migration failed or already up to date"

# Esegui i seeder
echo "Running seeders..."
php artisan db:seed --force -n || echo "Run seeders failed!"

# Crea il link simbolico per lo storage pubblico
echo "Creating storage link..."
php artisan storage:link || echo "Storage link already exists"
