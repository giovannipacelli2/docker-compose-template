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

# Fix permessi storage (importante quando si usa un volume)
echo "Setting up storage permissions..."
chown -R www-data:www-data /var/www/html/storage
chmod -R 775 /var/www/html/storage

# Crea tutte le sottocartelle necessarie se non esistono
mkdir -p /var/www/html/storage/app/public
mkdir -p /var/www/html/storage/framework/cache
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/framework/views
mkdir -p /var/www/html/storage/logs

chmod 777 -R /var/www/html/storage/
chown -R www-data:www-data /var/www/

# Attendi che il database sia pronto

# Ottimizza per produzione
if [ "$APP_ENV" != "production" ]; then
    wait_for_db
else
    check_db
fi

# Avvia Apache
echo "Starting Apache..."
exec apache2-foreground
