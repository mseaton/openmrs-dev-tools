#!/bin/bash

echo "Creating runtime properties file"
touch $ENV_DIR/openmrs-runtime.properties
cat > $ENV_DIR/openmrs-runtime.properties <<EOL

connection.url=jdbc:mysql://localhost:3306/openmrs_$ENV_NAME?autoReconnect=true&sessionVariables=storage_engine=InnoDB&useUnicode=true&characterEncoding=UTF-8
connection.username=openmrs
connection.password=openmrs

application_data_directory=$ENV_DIR/openmrs

module.allow_web_admin=true
auto_update_database=false

junit.username=admin
junit.password=Admin123

pih.config=lacolline

local_zl_identifier_generator_enabled=true
local_zl_identifier_generator_prefix=Y
remote_zlidentifier_url=http://localhost:$TOMCAT_HTTP_PORT/openmrs/module/idgen/exportIdentifiers.form?source={LOCAL_SOURCE_ID}&comment=Testing+$ENV_NAME
remote_zlidentifier_username=admin
remote_zlidentifier_password=Admin123

uiFramework.developmentFolder=$SOURCE_FOLDER
uiFramework.developmentModules=
EOL

echo "Creating feature toggles properties file"
touch $ENV_DIR/openmrs/feature_toggles.properties
cat > $ENV_DIR/openmrs/feature_toggles.properties <<EOL
registerTestPatient=true
myAccountFeature=true
consult_note_confirm_diagnoses=true
consultNoteDispositions=true
deleteEncounter=true
notifiableDiseasesReport=true
import_mpi_patients=true
radiologyTab=true
emergencyCheckin=true
surgicalOperativeNote=true
inpatientsList=true
noActiveVisitView=true
liveCheckin=true
editVisitDates=true
orderRadiologyRetrospective=true
editConsultNotes=true
editTransferAndDischargeNotes=true
enterRetrospectiveConsultNoteInActiveVisit=true
dispenseMedicine=true
appointmentschedulingOldUI=true
clinicianCreateRetroConsultNote=true
reportingui_adHocAnalysis=true
new_appointment_scheduling_ui=true
awaitingAdmission=true
newPaperRecordLabelTemplate=true
radiologyContrastStudies=true
enableNewPatientHeader=true
mirebalais.consult=true
mirebalais.edConsult=true
mirebalais.admissionNote=true
EOL

DISTRIBUTION_MODULE=mirebalais
