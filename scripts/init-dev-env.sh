#!/bin/bash

check_dependency() {
	if ! command -v "$1" >/dev/null 2>&1; then
		echo "Install $1 to use this script"
		exit 1
	fi
}

check_dependency "docker"

docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):/var/www/html" \
    -w /var/www/html \
    laravelsail/php81-composer:latest \
    composer install --ignore-platform-reqs

if ! [ -f .env ]; then
    cp .env.example .env
fi

../vendor/bin/sail up -d # pour le premier lancement

echo "Sleeping 20s to wait for sail containers to be ready"
sleep 20

../vendor/bin/sail npm install # pour installer les dépendances pour le front end

../vendor/bin/sail artisan migrate:fresh --seed
