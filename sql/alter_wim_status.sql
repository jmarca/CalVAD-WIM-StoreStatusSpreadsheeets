-- run these if you are updating an older db table definition

alter table wim_status add column internal_class_notes character varying;
alter table wim_status add column internal_weight_notes character varying;
alter table wim_status add column parser_decisions_notes character varying;


-- update as of the 08 2013 spreadsheet
update wim_status_codes
set description = 'Partial Bad: Site has enough good data to submit for reporting'
where status = 'P/B';


-- new ones as of the 08 2013 spreadsheet
insert into wim_status_codes (status,description) values
    ('N/C','Needs Calibration: Weights no good - Do not use for the Truck Weight Study or SHRP until re-calibrated.'),
    ('E','Evaluation in progress'),
    ('B/G','Bad Good?  Undefined in spreadsheet key, but used'),
    ('G/B','Good Bad?  Undefined in spreadsheet key, but used')
;

-- And now allowing 'UNDEFINED' too
insert into wim_status_codes (status,description) values
    ('UNDEFINED','Entry not defined in monthly status spreadsheet.')
;
