package Linux::Virt::Plugin::LXC;
# ABSTRACT: LXC (Linux Containers) plugin for Linux::Virt

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

extends 'Linux::Virt::Plugin';

sub _init_priority { return 10; }

sub is_host {
    my $self = shift;
    my $opts = shift || {};

    my $cmd = '/usr/bin/lxc-checkconfig';
    return unless -x $cmd;
    return $self->sys()->run_cmd( $cmd, $opts );
} ## end sub is_host

sub is_vm {
    my $self = shift;

    # TODO can't find out, yet :(
    return;
} ## end sub is_vm

sub vms {
    my $self        = shift;
    my $vserver_ref = shift;
    my $opts        = shift || {};

    return unless -x '/usr/bin/lxc-ls';
    return unless -x '/usr/bin/lxc-info';

    local $ENV{LANG} = 'C';
    my $LXC;
    if ( !open( $LXC, '-|', '/usr/bin/lxc-ls' ) ) {
        my $msg = "Could not execute /usr/bin/lxc-ls! Is lxc installed?: $!";
        $self->logger()->log( message => $msg, level => 'warning', );
        return;
    }
    while ( my $line = <$LXC> ) {
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        my $name = $line;
        $vserver_ref->{$name}{'virt'}{'type'} = 'lxc';

    } ## end while ( my $line = <$LXC>)
    close($LXC);

    foreach my $vs ( keys %{$vserver_ref} ) {
        next if !$vserver_ref->{$vs}{'virt'}{'type'} eq 'lxc';
        local $opts->{'CaptureOutput'} = 1;
        my $status = $self->sys()->run_cmd( '/usr/bin/lxc-info --name=' . $vs, $opts );
        if ( $status !~ m/RUNNING/ ) {
            delete( $vserver_ref->{$vs} );
        }
    } ## end foreach my $vs ( keys %{$vserver_ref...})
    return 1;
} ## end sub vms

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Linux::Virt::Plugin::LXC - LXC plugin for Linux::Virt.

=method is_host

Returns a true value if this is run on a LXC capable host.

=method is_vm

Returns a true value if this is run inside an LXC guest.

=method vms

Returns a list of all LXC VMs on the local host.

=cut
