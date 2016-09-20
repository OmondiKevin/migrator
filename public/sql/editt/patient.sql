SELECT
	p.person_id AS medical_record_number,
	pi.identifier AS patient_number_ccc,
	pe.first_name,
	pe.surname AS last_name,
	pe.other_names AS other_name,
	pe.date_of_birth AS dob,
	CASE WHEN pe.sex LIKE '%female%' THEN 2
	WHEN pe.sex LIKE '%male%' THEN 1
	ELSE '' END AS gender,
	CASE 
		WHEN pa.tel_no1 = '' THEN pa.tel_no1
		ELSE pa.tel_no2 
	END AS phone, 
	pa.physical_address	AS physical,
	p.chronic_illnesses AS other_illnesses,
	p.smoker AS smoke,
	p.drinker AS alcohol,
	p.enrollment_date AS date_enrolled,
	ps.name AS source,
	su.name AS supported_by,
	p.created_on AS timestamp,
	{destination_facility_code} AS facility_code,
	st.name AS service,
	r.code AS start_regimen,
	r.code AS current_regimen,
	v.next_appointment_date AS nextappointment,
	p.therapy_start_date AS start_regimen_date,
	pas.name AS current_status,
	p.drug_allergies AS drug_allergies,
	f.code AS transfer_from,
	{destination_store_id} AS ccc_store_sp 
FROM patient p
LEFT JOIN person pe ON pe.id = p.person_id
LEFT JOIN patient_identifier pi ON pi.patient_id = p.person_id
LEFT JOIN person_address pa ON pa.person_id = pe.id 
LEFT JOIN patient_service_type pst ON pst.patient_id = p.person_id
LEFT JOIN service_type st ON st.id = pst.service_type_id
LEFT JOIN patient_source ps ON ps.id = p.patient_source_id
LEFT JOIN supporting_organization su ON su.id = p.supporting_organization_id
LEFT JOIN regimen r ON r.id = p.start_regimen_id
LEFT JOIN patient_status pas ON pas.id=p.patient_status_id
LEFT JOIN facility f ON f.id = p.from_facility_id
LEFT JOIN (
	SELECT patient_id, MAX(next_appointment_date) as next_appointment_date 
	FROM visit 
	WHERE next_appointment_date IS NOT NULL 
	GROUP BY patient_id
) v ON v.patient_id = p.person_id
WHERE p.{migration_flag_column} = {migration_flag_default}
GROUP BY p.id
LIMIT {migration_limit}
OFFSET {migration_offset}//