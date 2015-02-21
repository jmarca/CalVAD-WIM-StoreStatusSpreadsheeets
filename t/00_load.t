use strict;
use warnings;
use Test::More; # see done_testing()

require_ok( 'CalVAD::WIM::StoreStatusSpreadsheeets');

my $obj;
eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new(); };
is($obj, undef, 'object creation should not work without required fields');

eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new('host'=>'bleh'); };
is($obj, undef, 'object creation should not work without required fields');

eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new('host'=>'bleh',
                                                         'user'=>'blah',
                                                         'pass'=>'secret',
                                                        ); };
is($obj, undef, 'object creation should not work without required fields');

eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new('host'=>'bleh',
                                                         'db'=>'boo',
                                                         'user'=>'blah',
                                                        ); };
is($obj, undef, 'object creation should not work without required fields');
eval { $obj = CalVAD::WIM::StoreStatusSpreadsheeets->new('host'=>'bleh',
                                                         'db'=>"boo",
                                                         'user'=>'blah',
                                                         'data'=>[1,2,3]
                                                        ); };
if($@) {
  warn $@;
}
isnt($obj, undef, 'object creation should work with all required fields');
like($obj,qr/CalVAD::WIM::StoreStatusSpreadsheeets/,'it is okay');
done_testing(7);
