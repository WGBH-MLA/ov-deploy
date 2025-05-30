DB_URL="postgresql://$OV_DB_USER:$OV_DB_PASSWORD@$OV_DB_HOST:$OV_DB_PORT"
export "PGPASSWORD=$OV_DB_PASSWORD"

MAX_RETRIES=5
# Check if the database is ready
until pg_isready -h "$OV_DB_HOST" -p "$OV_DB_PORT" -U "$OV_DB_USER"; do
  if [ $((MAX_RETRIES--)) -eq 0 ]; then
    echo "PostgreSQL is not ready after multiple attempts. Exiting..."
    exit 1
  fi
  echo "Waiting for PostgreSQL to be ready..."
  sleep 5
done

# Check if the database exists by attempting to connect
MESSAGE=$(psql "$DB_URL/$OV_DB_NAME" -c '\q' 2>&1 > /dev/null)

if [ $? -eq 0 ]; then
  echo "Database $OV_DB_NAME already exists. Exiting..."
  exit 0
fi

# Check for the right error message
if ! echo "$MESSAGE" | grep "database \"$OV_DB_NAME\" does not exist"; then
  echo "Uh oh!... we got a different error than expected: $MESSAGE"
  echo "Exiting without making any changes."
  exit 1
fi
echo "Database $OV_DB_NAME does not exist, creating..."
psql "$DB_URL" -c "CREATE DATABASE $OV_DB_NAME;" &&\
echo "Created db $OV_DB_NAME. Dumping the existing database..." &&\
pg_dump "$DB_URL/ov" > /tmp/dump.sql &&\
echo "Restoring the dump into the new database..." &&\
psql "$DB_URL/$OV_DB_NAME" -f /tmp/dump.sql &&\
echo "Database $OV_DB_NAME created and restored successfully!" &&\
exit 0 || {
  echo "Failed to create or restore the database."
  exit 1
}
