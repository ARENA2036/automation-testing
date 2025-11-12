#!/usr/local/bin/bash
# ==========================================
# Automatic Restore Script for portal-backend PostgreSQL (demo cluster)
# - Deletes existing data if present
# - Restores from latest backup automatically
# ==========================================

# --- Configuration ---
TARGET_CONTEXT=""                              # Target Kubernetes cluster e.g demo-cluster
RELEASE=""                                     # Helm release name e.g umbrella
NAMESPACE="umbrella-owais"                     # Namespace in target cluster
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"   # Dynamic project directory
BACKUP_FILE="$(ls -t "$PROJECT_DIR"/backup/portal-backend_full_backup_*.sql 2>/dev/null | head -n 1)"
POD="${RELEASE}-portal-backend-postgresql-0"
DB_USER=""                                      # DB user
DB_PASSWORD=""                                  # DB password
DATABASE=""
STATEFULSET="${RELEASE}-portal-backend-postgresql" # StatefulSet controlling DB

# --- Log setup ---
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/restore_$(date +%Y-%m-%d_%H-%M-%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "portal-backend PostgreSQL Automatic Restore"
echo "=========================================="
echo "Cluster Context : $TARGET_CONTEXT"
echo "Namespace       : $NAMESPACE"
echo "Backup File     : $BACKUP_FILE"
echo "------------------------------------------"

# --- Switch to target cluster ---
echo "Switching to Kubernetes context: $TARGET_CONTEXT"
kubectl config use-context "$TARGET_CONTEXT" >/dev/null
sleep 3
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Current context: $CURRENT_CONTEXT"
echo "------------------------------------------"

# --- Check StatefulSet existence ---
echo "Checking StatefulSet: $STATEFULSET..."
if ! kubectl get statefulset "$STATEFULSET" -n "$NAMESPACE" &>/dev/null; then
    echo "StatefulSet $STATEFULSET not found in namespace $NAMESPACE. Exiting."
    exit 1
fi
echo "StatefulSet $STATEFULSET found"
echo "------------------------------------------"

# --- Copy backup file into pod ---
if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi
echo "Copying backup file into pod..."
kubectl cp "$BACKUP_FILE" "$NAMESPACE/$POD:/tmp/portal-backend_restore.sql"
kubectl exec -n "$NAMESPACE" "$POD" -- ls -lh /tmp/portal-backend_restore.sql
echo "Backup file copied"
echo "------------------------------------------"

# --- Check if database has existing data ---
echo "Checking if database contains data..."
ROW_COUNT=$(kubectl exec -n "$NAMESPACE" "$POD" -- sh -c "
export PGPASSWORD='$DB_PASSWORD';
psql -U $DB_USER -d $DATABASE -t -A -c \"
SELECT COALESCE(SUM(reltuples)::bigint,0)
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('pg_catalog','information_schema')
AND c.relkind='r';
\"")

ROW_COUNT=${ROW_COUNT//[[:space:]]/}
echo "Estimated total rows: ${ROW_COUNT:-0}"

# --- Automatically truncate tables if data exists ---
if [[ "$ROW_COUNT" -gt 0 ]]; then
    echo "Data exists in $DATABASE (~$ROW_COUNT rows). Deleting all existing data..."
    kubectl exec -n "$NAMESPACE" -i "$POD" -- env PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DATABASE" -v ON_ERROR_STOP=1 <<'EOSQL'
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type='BASE TABLE'
          AND table_schema NOT IN ('pg_catalog','information_schema')
    LOOP
        EXECUTE format('TRUNCATE TABLE %I.%I CASCADE;', r.table_schema, r.table_name);
    END LOOP;
END
$$;
EOSQL
    echo "Existing data truncated successfully."
else
    echo "No existing data found — skipping deletion step."
fi

echo "------------------------------------------"

# --- Restore database from backup ---
echo "Restoring database $DATABASE..."
kubectl exec -n "$NAMESPACE" -i "$POD" -- env PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DATABASE" -f /tmp/portal-backend_restore.sql
echo "Database restored successfully."
echo "------------------------------------------"

# --- Cleanup ---
echo "Removing temporary restore file..."
kubectl exec -n "$NAMESPACE" "$POD" -- rm -f /tmp/portal-backend_restore.sql
echo "Cleanup done."
echo "------------------------------------------"

# --- Restart StatefulSet ---
echo "Restarting StatefulSet $STATEFULSET..."
kubectl rollout restart statefulset "$STATEFULSET" -n "$NAMESPACE"
kubectl rollout status statefulset "$STATEFULSET" -n "$NAMESPACE"
echo "StatefulSet restarted successfully."
echo "------------------------------------------"

echo "Automatic restore completed at $(date)"
echo "Logs saved to: $LOG_FILE"
echo "=========================================="
