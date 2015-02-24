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
is_deeply($current_status_codes,{},'nothing in the db, but the query worked');


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
