package Linux::Virt::Plugin::KVM;
# ABSTRACT: KVM plugin for Linux::Virt

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

extends 'Linux::Virt::Plugin::Libvirt';

sub _init_priority { return 10; }

sub _init_type {
    return 'kvm';
}

sub is_host {
    my $proc_modules = '/proc/modules';
    if ( open( my $FH, '<', $proc_modules ) ) {
        my @lines = <$FH>;
        close($FH);
        foreach my $line ( @lines ) {

            # is the kvm_{intel,amd,...} module loaded?
            if ( $line =~ m/^kvm_/i ) {
                close($FH);
                return 1;
            }
        } ## end while ( my $line = <$FH> )
    } ## end if ( open( my $FH, "<"...))
    return;
} ## end sub is_host

sub is_vm {

    my $proc_cpuinfo = '/proc/cpuinfo';
    if ( open( my $FH, '<', $proc_cpuinfo ) ) {
        my @lines = <$FH>;
        close($FH);
        foreach my $line ( @lines ) {
            # is this a QEMU CPU?
            if ( $line =~ m/QEMU Virtual CPU/i ) {
                close($FH);
                return 1;
            }
        } ## end while ( my $line = <$FH> )
    } ## end if ( open( my $FH, '<'...))
    return;
} ## end sub is_vm

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Linux::Virt::Plugin::KVM - KVM plugin for Linux::Virt.

=method is_host

Returns a true value if run on a KVM capable host.

=method is_vm

Returns a true value if run inside a KVM VM.

=cut
