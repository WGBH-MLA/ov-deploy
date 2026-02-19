DB_URL="postgresql://$OV_DB_USER:$OV_DB_PASSWORD@$OV_DB_HOST:$OV_DB_PORT"
export "PGPASSWORD=$OV_DB_PASSWORD"

MAX_RETRIES=5
# Check if the database is ready
until pg_isready -h "$OV_DB_HOST" -p "$OV_DB_PORT" -U "$OV_DB_USER"; do
  if [ $((MAX_RETRIES--)) -eq 0 ]; then
    >&2 echo "Error: PostgreSQL is not ready after multiple attempts. Exiting..."
    exit 1
  fi
  echo "Waiting for PostgreSQL to be ready..."
  sleep 5
done

# Check if the database exists by attempting to connect
MESSAGE=$(psql "$DB_URL/$OV_DB_NAME" -c '\q' 2>&1 > /dev/null)

if [ $? -ne 0 ]; then
  echo "Error: Failed to connect to the database. Message: $MESSAGE"
  exit 1
fi

echo "Attempting to dump | restore into the new database..." &&\
pg_dump "$DB_URL/$SOURCE_DB_NAME" | psql "$DB_URL/$OV_DB_NAME" &&\
echo "Database $OV_DB_NAME created and restored successfully!" &&\
exit 0 || {
  >&2 echo "Failed to create or restore the database."
  exit 1
}
