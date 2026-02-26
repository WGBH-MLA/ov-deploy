SOURCE_DB_URL="postgresql://$SOURCE_DB_USER:$SOURCE_DB_PASSWORD@$SOURCE_DB_HOST:5432"
DEST_DB_URL="postgresql://$OV_DB_USER:$OV_DB_PASSWORD@$OV_DB_HOST:$OV_DB_PORT"

MAX_RETRIES=5
# Check if the database is ready
until pg_isready -h "$OV_DB_HOST" -p "$OV_DB_PORT" -U "$OV_DB_USER"; do
  if [ $((MAX_RETRIES--)) -eq 0 ]; then
    >&2 echo "Error: PostgreSQL host ${OV_DB_HOST} is not ready after multiple attempts. Exiting..."
    exit 1
  fi
  echo "Waiting for PostgreSQL host ${OV_DB_HOST} to be ready..."
  sleep 5
done
echo "PostgreSQL host ${OV_DB_HOST} is ready."

# Check if the database exists by attempting to connect
MESSAGE=$(psql "$DEST_DB_URL/$OV_DB_NAME" -c '\q' 2>&1 > /dev/null)

if [ $? -ne 0 ]; then
  echo "Error: Failed to connect to $OV_DB_NAME. Message: $MESSAGE"
  exit 1
fi
echo "Connected to $OV_DB_NAME successfully."

echo "Attempting to dump | restore from $SOURCE_DB_NAME to $OV_DB_NAME..."
pg_dump "$SOURCE_DB_URL/$SOURCE_DB_NAME" | psql "$DEST_DB_URL/$OV_DB_NAME" &&\
echo "Database $OV_DB_NAME synced successfully!" &&\
exit 0 || {
  >&2 echo "Failed to create or restore the database."
  exit 1
}
