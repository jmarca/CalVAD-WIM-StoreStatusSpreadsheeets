# ABSTRACT: turns baubles into trinkets
package CalVAD::WIM::StoreStatusSpreadsheeets;

use Moose;
use Carp;
use Data::Dumper;
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
sub _save_chunk{
    my $self = shift;
    my $bulk = shift;
    my $rs = $self->resultset('Public::WimStatus');
    eval{
        $self->populate('Public::WimStatus',$bulk);
    };
    if($@){
        return $@;
    }
    return;
}

sub save_data {
    my $self = shift;
    my $bulk = [@{$self->data}];
    # entries might already be in database, so do the usual strategy
    # of bulk save a bunch at a time, and if there is an issue, drop
    # down to one by one
    my $result = $self->_save_chunk($bulk);
    if($result){
        # probably a unique key collision.  Don't panic
        if($result =~ /duplicate key value/ || $result =~ /violates foreign key constraint/){
            carp 'duplicate key detected or bad status value, saving in groups of 100';
            # save groups of 10
            while(@{$bulk}){
                my @some = splice @{$bulk},0,100;
                $result = $self->_save_chunk(\@some);
                if($result && $result =~ /duplicate key value/ || $result =~ /violates foreign key constraint/){
                    carp 'drop down to individual rows';
                    for my $row (@some){
                        $result = $self->_save_chunk([$row]);
                        if($result && $result =~ /violates foreign key constraint/){
                            carp "status code problem.  Please check the spreadsheet for an unknown status code: ", Dumper $row ; #,$result;
                        }
                    }
                }
            }

        }else{
            croak $result;
        }
    }
    return;
}
1;
