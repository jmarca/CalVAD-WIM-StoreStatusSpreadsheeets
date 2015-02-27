-- run these if you are updating an older db table definition

alter table wim_status add column internal_class_notes character varying;
alter table wim_status add column internal_weight_notes character varying;
alter table wim_status add column parser_decisions_notes character varying;
