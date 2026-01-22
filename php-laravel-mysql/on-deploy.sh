#!/bin/bash
set -e

if [[ "$1" = "no-action" ]]; then
    echo "$1 detected..."
    echo "Action Stopped!"
    exit 0
fi
echo "starting script..."

# Rimuoviamo eventuali cache residue copiate per errore
rm -f bootstrap/cache/*.php

echo "Discovery packages..."
php artisan package:discover --ansi

echo "Clearing cache..."
php artisan config:clear
php artisan ms:update

# Esegui le migrazioni
echo "Running migrations..."
php artisan migrate --force --no-interaction || echo "Migration failed or already up to date"

# Esegui i seeder
echo "Fresh scopes..."
php artisan db:seed RoleScopeSeeder --force -n || echo "Run RoleScopeSeeder failed!"

# Ottimizza per produzione
if [ "$APP_ENV" = "production" ]; then
    echo "Optimizing application..."
    php artisan config:cache
    php artisan optimize:clear
    php artisan route:cache
    #php artisan view:cache
fi
