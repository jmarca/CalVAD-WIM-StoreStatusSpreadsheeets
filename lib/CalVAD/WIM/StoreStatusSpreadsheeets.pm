# ABSTRACT: turns baubles into trinkets
package CalVAD::WIM::StoreStatusSpreadsheeets;

use Moose;

my $noop = sub {};


has 'data' => (
    is=>'ro',
    isa=>'ArrayRef',
    required => 1,
    );

has 'status_codes' => (
    is=>'ro',
    isa=>'HashRef',
    lazy=>1,
    init_arg => undef,
    builder => '_build_status_codes',
    );

has 'new_status_codes' => (
    is=>'rw',
    lazy=>1,
    isa=>'HashRef',
    init_arg => undef,
    builder => '_build_new_status_codes',
    );

sub _build_new_status_codes {
    return {};
}

sub _build_status_codes {
    my $self = shift;
    my $rs = $self->resultset('Public::WimStatusCode');
    my @all = $rs->all();
    my $hash={};
    for(@all){
        $hash->{ $_->status } = 1;
    }
    return $hash;
}

sub check_status_code {
    my $self = shift;
    my $code = shift;
    if(!$self->status_codes->{$code} &&
       !$self->new_status_codes->{$code}){
        $self->resultset('Public::WimStatusCode')->create(
            { 'status' => $code }
            );
        $self->new_status_codes->{$code} = 1
    }
    return;
}

has 'inner_loop_method' =>
    ( is => 'ro',
      isa => 'CodeRef',
      init_arg => undef,
      builder => '_build_inner_loop_method',);

sub _build_inner_loop_method {
    my $inner_loop_method = sub  {
        # this will eventually copy data into the Status tables
        return # noop for now
    };
    return $inner_loop_method;
}

with 'Spatialvds::CopyIn';
# with 'CouchDB::Trackable';

1;
