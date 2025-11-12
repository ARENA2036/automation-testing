#!/bin/bash

# ==================================================================
# Database Verification Script Runner (with Kubernetes port-forward)
# ==================================================================

# --- Configuration ---
TARGET_CONTEXT=""                                  # Target Kubernetes cluster demo-cluster"
NAMESPACE=""                                       # Namespace in target cluster
RELEASE=""                                         # Helm release name e.g umbrella
# DB_SERVICE="umbrella-sharedidp-postgresql"       # PostgreSQL service name
DB_SERVICE="${RELEASE}-centralidp-postgresql"      # PostgreSQL service name
DB_PORT=5432                                       # PostgreSQL port in cluster
LOCAL_PORT=5432                                    # Local port for port-forwarding
# DB_USER=""                                       # Database user
# DB_NAME=""                                       # Database name
# DB_PASSWORD=""                                   # Database password
SQL_SCRIPT="verify_db.sql"                         # SQL verification script
REPORT_FILE="db_verification_report_demo_centralidp-postgresql.txt"       # Output report file

# --- Switch to the target Kubernetes context ---
echo "Switching to Kubernetes context: $TARGET_CONTEXT"
kubectl config use-context "$TARGET_CONTEXT" >/dev/null 2>&1
sleep 5
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Current context: $CURRENT_CONTEXT"
if [ $? -ne 0 ]; then
    echo "Error: Could not switch to context $TARGET_CONTEXT"
    exit 1
fi

# --- Export PostgreSQL password for psql ---
export PGPASSWORD="$DB_PASSWORD"

# --- Start port-forwarding in the background ---
echo "Starting port-forward to service $DB_SERVICE in namespace $NAMESPACE..."
kubectl port-forward svc/"$DB_SERVICE" "$LOCAL_PORT":"$DB_PORT" -n "$NAMESPACE" >/dev/null 2>&1 &
PF_PID=$!

# Give port-forward some time to establish
sleep 3

# --- Test connection ---
echo "Testing PostgreSQL connection on localhost:$LOCAL_PORT..."
pg_isready -h localhost -p "$LOCAL_PORT" -U "$DB_USER" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Cannot connect to PostgreSQL on localhost:$LOCAL_PORT"
    kill $PF_PID
    exit 1
fi

# --- Run SQL verification script ---
echo "Running database verification script..."
psql -h localhost -p "$LOCAL_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SQL_SCRIPT" -o "$REPORT_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to execute verification script"
    kill $PF_PID
    exit 1
fi

# --- Stop port-forwarding ---
kill $PF_PID

echo "Database verification report generated: $REPORT_FILE"
