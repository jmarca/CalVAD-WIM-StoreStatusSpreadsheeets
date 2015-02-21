use Test::More; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::StoreStatusSpreadsheeets;


my $host = $ENV{PGHOST};
my $port = $ENV{PGPORT};
my $db = $ENV{PGDATABASE};
my $user = $ENV{PGTESTUSER} || $ENV{PGUSER};
my $pass = $ENV{PGTESTPASS};

my $blank_data = [1,2,3];
# first try without $pass, leverage .pgpass file?

isnt($port,undef,'need a valid port defined in env PGPORT');
isnt($user,undef,'need a valid user defined in env PGUSER');
isnt($db,undef,'need a valid db defined in env PGDATABASE');
isnt($host,undef,'need a valid host defined in env PGHOST');

my $obj;
eval {
  $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new('host'=>$host,
                                                    'db'=>$port,
                                                    'user'=>$user,
                                                    'data'=>$blank_data
                                                   );
};
if($@) {
  warn $@;
}

isnt($obj, undef, 'object creation should work with all required fields');
like($obj,qr/CalVAD::WIM::StoreStatusSpreadsheeets/,'it is okay');


done_testing(6);
