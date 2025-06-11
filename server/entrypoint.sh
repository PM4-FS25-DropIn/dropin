#!/bin/sh

echo "Applying database migrations..."
npx supabase db push --db-url "${DB_CONNECTION_STRING}"

echo "Starting the application..."
npm run start-docker