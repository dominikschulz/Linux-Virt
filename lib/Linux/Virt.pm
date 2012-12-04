package Linux::Virt;
# ABSTRACT: unified Linux virtualization wrapper

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
use Try::Tiny;

# extends ...
# has ...
# with ...
with 'Config::Yak::OrderedPlugins' => { -version => 0.18 };
# initializers ...

sub _plugin_base_class { return 'Linux::Virt::Plugin'; }

sub vms {
    my $self    = shift;
    my $running = shift;

    my $vm_ref = {};

    foreach my $virt ( keys %{ $self->plugins() } ) {
        try {
            $vm_ref->{$virt} = $self->plugins()->{$virt}->vms();
        } catch {
            $self->logger()->log( message => 'Failed to get vms from plugin '.$virt.' w/ error: '.$_, level => 'error', );
        };
    }

    return $vm_ref;
} ## end sub vms

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__


=head1 NAME

Linux::Virt - Linux virtualization manager

=method vms

Report all (supported) VMs found on the local host.


=cut
