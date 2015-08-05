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

DISTRIBUTION_MODULE=pihmalawi
