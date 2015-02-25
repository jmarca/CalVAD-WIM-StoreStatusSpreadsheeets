use Test::Modern;

use Carp;
use Data::Dumper;

use CalVAD::WIM::StoreStatusSpreadsheeets;

my $obj;
eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new(); };
is($obj, undef, 'object creation should not work without required fields');

eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new('host_psql'=>'bleh'); };
is($obj, undef, 'object creation should not work without required fields');

eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new('host_psql'=>'bleh',
                                                         'username_psql'=>'blah',
                                                         'pass_psql'=>'secret',
                                                        ); };
is($obj, undef, 'object creation should not work without required fields');

eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new('host_psql'=>'bleh',
                                                         'dbname_psql'=>'boo',
                                                         'username_psql'=>'blah',
                                                        ); };
is($obj, undef, 'object creation should not work without required fields');
eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new('host_psql'=>'bleh',
                                                         'port_psql'=>5432,
                                                         'dbname_psql'=>'boo',
                                                         'username_psql'=>'blah',
                                                         'password_psql'=>'',
                                                         'data'=>[1,2,3]
                                                        ); };
if($@) {
  warn $@;
}
isnt($obj, undef, 'object creation should work with all required fields');
like($obj,qr/CalVAD::WIM::StoreStatusSpreadsheeets/,'it is okay');

done_testing(7);
