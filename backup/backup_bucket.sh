#!/bin/bash

# Variables
NAMESPACE="default"        # Change this if your MySQL is in a different namespace
DEPLOYMENT_NAME="mysql"    # Change this to the name of your MySQL StatefulSet
MYSQL_POD=$(microk8s kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME,tier=database -o jsonpath='{.items[0].metadata.name}')
BACKUP_DIR="./backups"     # Directory where you want to save the backup
BACKUP_FILE="$BACKUP_DIR/backup_$(date +'%Y%m%d%H%M%S').sql"
DB_NAME=$(microk8s kubectl get configmap mysql-conf -o jsonpath='{.data.dbName}') # Fetch database name from ConfigMap
DB_USER=$(microk8s kubectl get secret mysql-credentials -o jsonpath='{.data.mysql_user}' | base64 --decode)  # Fetch MySQL user from secret
DB_PASS=$(microk8s kubectl get secret mysql-credentials -o jsonpath='{.data.mysql_password}' | base64 --decode)  # Fetch MySQL password from secret
GCS_BUCKET_NAME="infra-mysql-backup-bucket"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Perform backup
microk8s kubectl exec -n $NAMESPACE $MYSQL_POD -- \
    mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"
    gzip ${BACKUP_FILE}
    BACKUP_FILE_GZ="${BACKUP_FILE}.gz"
    gsutil cp ${BACKUP_FILE_GZ} gs://${GCS_BUCKET_NAME}/
    gsutil --version
else
    echo "Backup failed"
fi
