package Linux::Virt::Plugin::Xen;
# ABSTRACT: Xen plugin for Linux::Virt

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
    return 'xen';
}

sub is_host {    # dom0
    my $self     = shift;
    my $xen_caps = "/proc/xen/capabilities";
    if ( -f $xen_caps ) {
        if ( open( my $FH, "<", $xen_caps ) ) {
            while ( my $line = <$FH> ) {
                if ( $line =~ m/control_d/i ) {
                    close($FH);
                    return 1;
                }
            } ## end while ( my $line = <$FH> )
            close($FH);
        } ## end if ( open( my $FH, "<"...))
    } ## end if ( -f $xen_caps )
    return;
} ## end sub is_host

sub is_vm {    # domu
    my $self     = shift;
    my $xen_caps = "/proc/xen/capabilities";

    # xen_caps must be present and NOT contain control_d
    if ( -f $xen_caps ) {
        if ( open( my $FH, "<", $xen_caps ) ) {
            while ( my $line = <$FH> ) {
                if ( $line =~ m/control_d/i ) {
                    close($FH);
                    return;
                }
            } ## end while ( my $line = <$FH> )
            close($FH);
        } ## end if ( open( my $FH, "<"...))
        return 1;
    } ## end if ( -f $xen_caps )
    return;
} ## end sub is_vm

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Linux::Virt::Xen - Xen plugin for Linux::Virt

=method is_host

This method will return a true value if invoked in an xen (capeable) host (dom0).

=method is_vm

This method will return a true value if invoked in a xen vm (domU)

=cut
