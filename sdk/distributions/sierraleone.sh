#!/bin/bash

echo "Creating runtime properties file"
touch $ENV_DIR/openmrs-runtime.properties
cat > $ENV_DIR/openmrs-runtime.properties <<EOL

connection.url=jdbc:mysql://localhost:3306/$DB_NAME?autoReconnect=true&sessionVariables=storage_engine=InnoDB&useUnicode=true&characterEncoding=UTF-8
connection.username=openmrs
connection.password=openmrs

application_data_directory=$ENV_DIR/openmrs

module.allow_web_admin=true
auto_update_database=false

junit.username=admin
junit.password=Admin123

uiFramework.developmentFolder=$SOURCE_FOLDER
uiFramework.developmentModules=
EOL

BAHMNI_DIR=$ENV_DIR/openmrs/bahmni
BAHMNI_PATIENT_IMAGES_DIR=$BAHMNI_DIR/patient_images
BAHMNI_DOCUMENT_IMAGES_DIR=$BAHMNI_DIR/document_images

mkdir $BAHMNI_DIR
mkdir $BAHMNI_PATIENT_IMAGES_DIR
mkdir $BAHMNI_DOCUMENT_IMAGES_DIR

echo "Creating bahmnicore.properties file"
touch $ENV_DIR/openmrs/bahmnicore.properties
cat > $ENV_DIR/openmrs/bahmnicore.properties <<EOL

bahmnicore.images.directory=$BAHMNI_PATIENT_IMAGES_DIR
bahmnicore.urls.patientimages=/patient_images
bahmnicore.documents.baseDirectory=$BAHMNI_DOCUMENT_IMAGES_DIR

openelis.uri=http://localhost:8081/
patient.feed.uri=http://localhost:8081/openelis/ws/feed/patient/recent
feed.maxFailedEvents=10000
feed.connectionTimeoutInMilliseconds=10000
feed.replyTimeoutInMilliseconds=20000
EOL


DISTRIBUTION_MODULE=pihsierraleone
