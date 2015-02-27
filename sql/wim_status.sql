drop table wim_status;
drop table wim_status_codes;


CREATE TABLE wim_status_codes (
    status varchar not null primary key,
    description varchar not null
);
insert into wim_status_codes (status,description) values
    ('G', 'Good data'),
    ('XX', 'No data'),
    ('M','Marginal:  acceptable minor  errors.  Data is slighty above defined error limits.  Possible calibration'),
    ('B','Bad data.  Unusable  1 or  more  lanes'),
    ('*','Possible problem watching for next month data'),
    ('N/P','Needs Processing');

CREATE TABLE wim_status (
    site_no integer not null REFERENCES wim_stations (site_no)   ON DELETE RESTRICT,
    ts date not null,
    class_status varchar not null REFERENCES wim_status_codes(status) on delete restrict,
    class_notes varchar,
    internal_class_notes varchar,
    weight_status varchar not null REFERENCES wim_status_codes(status) on delete restrict,
    weight_notes varchar,
    internal_weight_notes varchar,
    parser_decisions_notes varchar,
    primary key (site_no,ts)
);

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
