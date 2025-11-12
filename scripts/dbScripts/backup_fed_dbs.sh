#!/usr/local/bin/bash
# Backup cluster PostgreSQL databases and upload to Azure Blob with logging

# --- Configuration ---
TARGET_CONTEXT=""                             # Target Kubernetes cluster. e.g demoCluster
NAMESPACE=""
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"  # Dynamic project directory
BACKUP_DIR="$PROJECT_DIR/backup"
LOG_DIR="$PROJECT_DIR/logs"
AZURE_ACCOUNT=""
AZURE_CONTAINER="database-backup"

# --- Switch to target cluster ---
echo "Switching to Kubernetes context: $TARGET_CONTEXT"
kubectl config use-context "$TARGET_CONTEXT"
# Wait briefly to ensure context switch is applied
sleep 5
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Current context: $CURRENT_CONTEXT"
echo "----------------------------------------"

# --- Prepare directories ---
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# --- Initialize log file ---
LOG_FILE="$LOG_DIR/backup_$(date +%Y-%m-%d_%H-%M-%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Backup started at $(date)"
echo "Logs will be saved to $LOG_FILE"
echo "----------------------------------------"

# --- Database definitions ---
DBS=(
  # Example 
  "service-a-db:namespace-service-a-db-0:user-a:password-a:database-a"
  "service-b-db:namespace-service-b-db-0:user-b:password-b:database-b"
  "service-c-db:namespace-service-c-db-0:user-c:password-c:database-c"
  "service-d-db:namespace-service-d-db-0:user-d:password-d:database-d"
  "service-e-db:namespace-service-e-db-0:user-e:password-e:database-e"
)

# --- Take backups ---
echo "Step 1: Taking backups..."
DATE_SUFFIX=$(date +%Y-%m-%d)
for ENTRY in "${DBS[@]}"; do
  IFS=":" read -r DB_NAME POD USER PASSWORD DATABASE <<< "$ENTRY"
  BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_full_backup_${DATE_SUFFIX}.sql"

  echo "Backing up $DB_NAME from pod $POD..."
  
  if [[ -z "$USER" || -z "$PASSWORD" || -z "$DATABASE" ]]; then
    echo "Skipping $DB_NAME: missing credentials or database name"
    continue
  fi

  if kubectl exec -n "$NAMESPACE" -i "$POD" -- \
    sh -c "PGPASSWORD='$PASSWORD' pg_dump -U $USER -d $DATABASE --no-owner --clean" > "$BACKUP_FILE"; then
    echo "Backup saved to $BACKUP_FILE"
  else
    echo "Backup FAILED for $DB_NAME"
    rm -f "$BACKUP_FILE"
  fi
  echo "----------------------------------------"
done

# --- Verify backups ---
echo "Step 2: Verifying backup files..."
for FILE in "$BACKUP_DIR"/*.sql; do
  if [[ -f "$FILE" && -s "$FILE" ]]; then
    echo "✔ Found backup file: $FILE"
    ls -lh "$FILE"
    head -n 5 "$FILE"
  else
    echo "Missing or empty backup file: $FILE"
  fi
  echo "----------------------------------------"
done

# --- Upload to Azure Blob ---
echo "Step 3: Uploading backups to Azure Blob Storage..."
for FILE in "$BACKUP_DIR"/*.sql; do
  if [[ -f "$FILE" && -s "$FILE" ]]; then
    echo "Uploading $FILE to Azure..."
    az storage blob upload \
      --account-name "$AZURE_ACCOUNT" \
      --container-name "$AZURE_CONTAINER" \
      --file "$FILE" \
      --name "$(basename "$FILE")" \
      --overwrite true \
      --only-show-errors
    echo "Uploaded: $(basename "$FILE")"
  else
    echo "Skipped upload: missing or empty $FILE"
  fi
  echo "----------------------------------------"
done

# --- Final check ---
echo "Uploaded files in Azure:"
az storage blob list \
  --account-name "$AZURE_ACCOUNT" \
  --container-name "$AZURE_CONTAINER" \
  --output table

echo "----------------------------------------"
echo "All backups completed at $(date)"
echo "Logs saved to: $LOG_FILE"