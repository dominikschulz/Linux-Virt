package Linux::Virt::Plugin;
# ABSTRACT: baseclass for an Linux::Virt plugin

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;
# use Carp;
# use English qw( -no_match_vars );
# use Try::Tiny;

use Sys::FS;
use Sys::Run;

# extends ...
# has ...
has 'sys' => (
    'is'      => 'rw',
    'isa'     => 'Sys::Run',
    'lazy'    => 1,
    'builder' => '_init_sys',
);

has 'fs' => (
    'is'      => 'rw',
    'isa'     => 'Sys::FS',
    'lazy'    => 1,
    'builder' => '_init_fs',
);

has 'priority' => (
    'is'    => 'ro',
    'isa'   => 'Int',
    'lazy'  => 1,
    'builder' => '_init_priority',
);
# with ...
with qw(Config::Yak::RequiredConfig Log::Tree::RequiredLogger);
# initializers ...
sub _init_priority { return 0; }

sub _init_sys {
    my $self = shift;

    my $Sys = Sys::Run::->new( { 'logger' => $self->logger(), } );

    return $Sys;
} ## end sub _init_sys

sub _init_fs {
    my $self = shift;

    my $FS = Sys::FS::->new(
        {
            'logger' => $self->logger(),
            'sys'    => $self->sys(),
        }
    );

    return $FS;
} ## end sub _init_fs

# your code here ...
sub is_host {
    my $self = shift;

    return;
}

sub is_vm {
    my $self = shift;

    return;
}

sub is_running {
    my $self   = shift;
    my $vsname = shift;

    # remove domain part
    $vsname =~ s/\.[a-z0-9]$//i;

    my $vs_ref = {};

    $self->vms($vs_ref);

    if ( $vs_ref->{$vsname} ) {
        return 1;
    }
    return;
}

sub create {
    my $self = shift;

    warn "The 'create' method is not implemented in ".ref($self).".\n";

    return;
} ## end sub create

## no critic (ProhibitBuiltinHomonyms)
sub delete {
## use critic
    my $self = shift;

    warn "This 'delete' method is not implemented in this ".ref($self).".\n";

    return;
} ## end sub delete

sub vms {
    my $self = shift;

    warn "This 'vms' method is not implemented in this ".ref($self).".\n";

    return;
} ## end sub vms

sub start {
    my $self = shift;

    warn "This 'start' method is not implemented in this ".ref($self).".\n";

    return;
} ## end sub start

sub stop {
    my $self = shift;

    warn "This 'stop' method is not implemented in this ".ref($self).".\n";

    return;
} ## end sub stop

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Linux::Virt::Plugin - Base class for all Linux::Virt plugins.

=head1 DESCRIPTION

This module is a base class for all Linux::Virt plugins.

=method create

Create a new VM. Subclasses should implement this method.

=method delete

Delete an existing VM. Subclasses should implement this method.

=method is_host

Returns a true value is this system is a (physical) host and able to run
VMs of this type. Subclasses should implement this method.

=method is_running

Returns true if the given VM is currently running.

=method is_vm

Returns true if this method is called within an VM. Subclasses should implement this method.

=method start

Start an existing VM. Subclasses should implement this method.

=method stop

Shutdown an existing VM. Subclasses should implement this method.

=method vms

List all available VMs. Subclasses should implement this method.

=cut

