use Test::More; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::StoreStatusSpreadsheeets;


my $host = $ENV{PGHOST} || '127.0.0.1';
my $port = $ENV{PGPORT} || 5432;
my $db = $ENV{PGDATABASE} || 'test_calvad_db';
my $user = $ENV{PGTESTUSER} || $ENV{PGUSER} || 'postgres';
my $pass = $ENV{PGTESTPASS} || '';

my $blank_data = [1,2,3];
# first try without $pass, leverage .pgpass file?

isnt($port,undef,'need a valid port defined in env PGPORT');
isnt($user,undef,'need a valid user defined in env PGUSER');
isnt($db,undef,'need a valid db defined in env PGDATABASE');
isnt($host,undef,'need a valid host defined in env PGHOST');

my $obj;
eval {
  $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new
      ('host_psql'=>$host,
       'port_psql'=>$port,
       'dbname_psql'=>$db,
       'username_psql'=>$user,
       'password_psql'=>$pass,
       'data'=>$blank_data
      );
};
if($@) {
  warn $@;
}

isnt($obj, undef, 'object creation should work with all required fields');
like($obj,qr/CalVAD::WIM::StoreStatusSpreadsheeets/,'it is okay');

my $connect;
eval {
  $connect = $obj->_connection_psql;
};
if($@) {
  warn $@;
}

isnt($connect, undef, 'db connection should be possible');
like($connect,qr/Testbed::Spatial::VDS::Schema/,'it is okay');

done_testing(8);
