use Test::Modern; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::StoreStatusSpreadsheeets;


# create a test database

use DBI;

my $host = $ENV{PGHOST} || '127.0.0.1';
my $port = $ENV{PGPORT} || 5432;
my $db = $ENV{PGTESTDATABASE} || 'test_db';
my $user = $ENV{PGTESTUSER} || $ENV{PGUSER} || 'postgres';
my $pass =  '';

my $admindb = $ENV{PGADMINDATABASE} || 'postgres';
my $adminuser = $ENV{PGADMINUSER} || 'postgres';


my $dbh;
eval{
    $dbh = DBI->connect("dbi:Pg:dbname=$admindb", $adminuser);
};
if($@) {
    croak $@;
}
my $create = "create database $db";
if($user ne $adminuser){
    $create .= " with owner $user";
}
eval {
        $dbh->do($create);
};
if($@) {
    carp 'test db creation failed';
    carp $@;
    carp Dumper [
        'host_psql'=>$host,
        'port_psql'=>$port,
        'dbname_psql'=>$db,
        'admin database'=>$admindb,
        'admin user'=>$adminuser,
        ];

    croak 'failed to create test database';
}

## deploy via DBIx::Class

use Testbed::Spatial::VDS::Schema;

my $schema = Testbed::Spatial::VDS::Schema->connect(
    "dbi:Pg:dbname=$db;host=$host;port=$port",
    $user,
    );

## deploy just the tables I'm going to be accessing during testing

my $deploy_result;
eval{
    $deploy_result =  $schema->deploy(
        { 'sources'=>["Public::WimStatus",
                      "Public::WimStatusCode"]});
};
if($@) {
    carp 'test db deploy failed';
    croak $@;
}


$schema->populate("Public::WimStatusCode",[
  {'status'=>'G','description'=>'Good data'},
  {'status'=>'XX','description'=>'No data'},
  {'status'=>'M','description'=>'Marginal:  acceptable minor  errors.  Data is slighty above defined error limits.  Possible calibration'},
  {'status'=>'B','description'=>'Bad data.  Unusable  1 or  more  lanes'},
  {'status'=>'*','description'=>'Possible problem watching for next month data'},
  {'status'=>'P/B','description'=>'Partially Bad'},
  {'status'=>'N/P','description'=>'Needs Processing'},
  {'status'=>'UNDEFINED','description'=>'Entry not defined in monthly status spreadsheet.'},
                  ]);
my $test_data = [
          {
            'weight_notes' => 'High Wgt Over LN #1,2,3',
            'internal_weight_notes' => 'High Wgtover Violations LN#1(31) & #2(24) and #3(3)',
            'site_no' => '59',
            'class_status' => 'G',
            'weight_status' => 'B',
            'class_notes' => '',
            'ts' => '2013-07-01',
            'internal_class_notes' => ''
          },
          {
            'internal_weight_notes' => '',
            'site_no' => '60',
            'weight_notes' => '',
            'class_status' => 'G',
            'weight_status' => 'G',
            'class_notes' => '',
            'ts' => '2013-07-01',
            'internal_class_notes' => ''
          },
          {
            'internal_weight_notes' => '',
            'site_no' => '61',
            'weight_notes' => 'DOWN',
            'class_notes' => 'DOWN',
            'class_status' => 'XX',
            'weight_status' => 'XX',
            'internal_class_notes' => '',
            'ts' => '2013-07-01'
          },
          {
            'class_notes' => 'DOWN',
            'weight_status' => 'XX',
            'class_status' => 'XX',
            'internal_class_notes' => '',
            'ts' => '2013-07-01',
            'internal_weight_notes' => '',
            'site_no' => '62',
            'weight_notes' => 'DOWN'
          },
          {
            'site_no' => '63',
            'internal_weight_notes' => '',
            'weight_notes' => 'DOWN',
            'ts' => '2013-07-01',
            'internal_class_notes' => '',
            'weight_status' => 'XX',
            'class_notes' => 'DOWN',
            'class_status' => 'XX'
          },
          {
            'ts' => '2013-07-01',
            'internal_class_notes' => '',
            'class_status' => 'G',
            'class_notes' => '',
            'weight_status' => 'G',
            'site_no' => '64',
            'internal_weight_notes' => '',
            'weight_notes' => ''
          },
# to test not crashing on unrecognized status
          {
            'ts' => '2013-07-01',
            'internal_class_notes' => '',
            'class_status' => 'Barkl',
            'class_notes' => '',
            'weight_status' => 'Sampo',
            'site_no' => '666',
            'internal_weight_notes' => '',
            'weight_notes' => ''
          },
          {
            'class_notes' => 'HIGH COUNT LANE 4',
            'weight_notes' => 'HiGH INVALIDS AND OVER WGT # 4 LANE',
            'parser_decisions_notes' => 'Setting UNDEFINED weight status to B based on RED (#ff0000) weight note color.  ',
            'ts' => '2010-02-01',
            'weight_status' => 'B',
            'class_status' => 'B',
            'site_no' => '67'
          },
          {
            'weight_notes' => '',
            'class_notes' => 'HIGH CLASS 0 AFTER JAN 25; HIGH COUNT LANE 6 FEB 8',
            'class_status' => 'P/B',
            'site_no' => '68',
            'weight_status' => 'UNDEFINED',
            'ts' => '2010-02-01',
            'parser_decisions_notes' => 'Forcing UNDEFINED on blank weight status.  '
          },
          {
            'weight_status' => 'G',
            'class_status' => 'G',
            'site_no' => '69',
            'ts' => '2010-02-01',
            'parser_decisions_notes' => 'Setting UNDEFINED weight status to G based on black or undefined weight note color.  ',
            'weight_notes' => 'LOW VOLUME WGT OVER ERRORS OK',
            'class_notes' => 'LOW VOLUME ERROR COUNTS'
          },
];


my $obj;
eval {
  $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new
      ('host_psql'=>$host,
       'port_psql'=>$port,
       'dbname_psql'=>$db,
       'username_psql'=>$user,
       'password_psql'=>$pass,
       'data'=>$test_data
      );
};
if($@) {
  carp $@;
}

isnt($obj, undef, 'object creation should work with all required fields');
like($obj,qr/CalVAD::WIM::StoreStatusSpreadsheeets/,'it is okay');

my $connect;
eval {
  $connect = $obj->_connection_psql;
};
if($@) {
  carp $@;
}

isnt($connect, undef, 'db connection should be possible');
like($connect,qr/Testbed::Spatial::VDS::Schema/,'it is okay');

my $new_status_codes  = $obj->new_status_codes;
is_deeply($new_status_codes,{},'before doing anything, new should be empty');

my $current_status_codes  = $obj->status_codes;
is_deeply($current_status_codes,
          {
    'G'=>1,
    'XX'=>1,
    'M'=>1,
    'B'=>1,
    '*'=>1,
    'P/B'=>1,
    'N/P'=>1,
},'nothing in the db, but the query worked');

my $warnings = [warnings { $obj->save_data() }];

cmp_deeply( $warnings,
           [
            TD->re('duplicate key detected or bad status value, saving in groups of 100'),
            TD->re('drop down to individual rows'),
            TD->re('status code problem.  Please check the spreadsheet for an unknown status code'),
           ],
           'got expected warnings',
    );


# check that it got stashed properly
for(@{$test_data}){
    my $wimstatus = $schema->resultset("Public::WimStatus")->find($_->{'site_no'},$_->{'ts'},
);
    if($_->{'site_no'} == 666){
        is($wimstatus,undef,'did not store the wonky entry');
    }else{
        my $stored = {
            'site_no'=>$wimstatus->get_column('site_no'),
            'ts'=>$wimstatus->ts,
            'class_status'=>$wimstatus->get_column('class_status'),
            'class_notes'=>$wimstatus->class_notes,
            'weight_status'=>$wimstatus->get_column('weight_status'),
            'weight_notes'=>$wimstatus->weight_notes,
            'internal_class_notes'=>$wimstatus->internal_class_notes,
            'internal_weight_notes'=>$wimstatus->internal_weight_notes,
        };
        is_deeply($stored,$_,"matched $_->{'site_no'}");
    }
}
# what happens when I try it again? should get a warning

$warnings = [warnings { $obj->save_data() }];
cmp_deeply( $warnings,
           [
            TD->re('duplicate key detected or bad status value, saving in groups of 100'),
            TD->re('drop down to individual rows'),
            TD->re('status code problem.  Please check the spreadsheet for an unknown status code'),
           ],
           'got expected warnings',
    );



done_testing;

END{
    $connect = undef;
    $dbh = undef;
    $obj = undef;
    $schema = undef;
    eval{
        $dbh = DBI->connect("dbi:Pg:dbname=$admindb", $adminuser);
        $dbh->do("drop database $db");
    };
    if($@){
        carp $@;
    }
}
