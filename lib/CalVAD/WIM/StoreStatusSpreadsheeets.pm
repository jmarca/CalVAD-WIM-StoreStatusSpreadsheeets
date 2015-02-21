use strict;
use warnings;
package CalVAD::WIM::StoreStatusSpreadsheeets;

use namespace::autoclean;
use Moose;

use Testbed::Spatial::VDS::Schema;


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
has 'db_connection' => (is=>'ro',
                        lazy=>1,
                        isa=>'Ref',
                        init_arg=>undef,
                        builder => '_build_db_connection',
                       );
has 'db' =>(
            is=>'ro',
            isa=>'Str',
            required=>1,
           );

has 'host'=>(
            is=>'ro',
            isa=>'Str',
            required=>1,
           );
has 'user'=>(
            is=>'ro',
            isa=>'Str',
            required=>1,
           );

has 'pass'=>(
            is=>'ro',
            isa=>'Str',
            required=>0,
           );

sub _build_db_connection {
  my $self = shift;
  my $db = $self->db;
  my $host = $self->host;
  my $user = $self->user;
  my $pass = $self->pass;
  my $vdb;
  if($pass){
      $vdb =
          Testbed::Spatial::VDS::Schema->connect( "dbi:Pg:dbname=$db;host=$host",
                                                  $user, $pass,
                                                  {RaiseError => 1,
                                                   PrintError => 0,
                                                   AutoCommit => 1}
          );
  }else{
      $vdb =
          Testbed::Spatial::VDS::Schema->connect( "dbi:Pg:dbname=$db;host=$host",
                                                  $user,
                                                  {RaiseError => 1,
                                                   PrintError => 0,
                                                   AutoCommit => 1}
          );

  }
  return $vdb;
}

sub _build_new_status_codes {
  return {};
}

sub _build_status_codes {
  my $self = shift;
  my $vdb = $self->vdb;
  my $rs = $vdb->resultset('Public::WimStatusCode');
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
    my $vdb = $self->vdb;
    $vdb->resultset('Public::WimStatusCode')->create( { 'status' => $code } );
    $self->new_status_codes->{$code} = 1
  }
  return;
}


__PACKAGE__->meta->make_immutable;

1;
