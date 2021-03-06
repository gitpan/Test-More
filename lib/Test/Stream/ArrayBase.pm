package Test::Stream::ArrayBase;
use strict;
use warnings;

use Test::Stream::ArrayBase::Meta;
use Test::Stream::Carp qw/confess croak/;
use Scalar::Util qw/blessed/;

use Test::Stream::Exporter();

sub import {
    my $class = shift;
    my $caller = caller;

    $class->apply_to($caller, @_);
}

sub apply_to {
    my $class = shift;
    my ($caller, %args) = @_;

    # Make the calling class an exporter.
    my $exp_meta = Test::Stream::Exporter::Meta->new($caller);
    Test::Stream::Exporter->export_to($caller, 'import')
        unless $args{no_import};

    my $ab_meta = Test::Stream::ArrayBase::Meta->new($caller);

    my $ISA = do { no strict 'refs'; \@{"$caller\::ISA"} };

    if ($args{base}) {
        my ($base) = grep { $_->isa($class) } @$ISA;

        croak "$caller is already a subclass of '$base', cannot subclass $args{base}"
            if $base;

        my $file = $args{base};
        $file =~ s{::}{/}g;
        $file .= ".pm";
        require $file unless $INC{$file};

        my $pmeta = Test::Stream::ArrayBase::Meta->get($args{base});
        croak "Base class '$args{base}' is not a subclass of $class!"
            unless $pmeta;

        push @$ISA => $args{base};

        $ab_meta->subclass($args{base});
    }
    elsif( !grep { $_->isa($class) } @$ISA) {
        push @$ISA => $class;
        $ab_meta->baseclass();
    }

    if ($args{accessors}) {
        $ab_meta->add_accessor($_) for @{$args{accessors}};
    }

    1;
}

sub new {
    my $class = shift;
    my $self = bless [@_], $class;
    $self->init if $self->can('init');
    return $self;
}

sub new_from_pairs {
    my $class = shift;
    my %params = @_;
    my $self = bless [], $class;

    while (my ($k, $v) = each %params) {
        my $const = uc($k);
        croak "$class has no accessor named '$k'" unless $class->can($const);
        my $id = $class->$const;
        $self->[$id] = $v;
    }

    $self->init if $self->can('init');
    return $self;
}

sub to_hash {
    my $array_obj = shift;
    my $meta = Test::Stream::ArrayBase::Meta->get(blessed $array_obj);
    my $fields = $meta->fields;
    my %out;
    for my $f (keys %$fields) {
        my $i = $fields->{$f};
        my $val = $array_obj->[$i];
        my $ao = blessed($val) && $val->isa(__PACKAGE__);
        $out{$f} = $ao ? $val->to_hash : $val;
    }
    return \%out;
};

1;

__END__

=encoding utf8

=head1 SOURCE

The source code repository for Test::More can be found at
F<http://github.com/Test-More/test-more/>.

=head1 MAINTAINER

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

The following people have all contributed to the Test-More dist (sorted using
VIM's sort function).

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=item Fergal Daly E<lt>fergal@esatclear.ie>E<gt>

=item Mark Fowler E<lt>mark@twoshortplanks.comE<gt>

=item Michael G Schwern E<lt>schwern@pobox.comE<gt>

=item 唐鳳

=back

=head1 COPYRIGHT

=over 4

=item Test::Stream

=item Test::Tester2

Copyright 2014 Chad Granum E<lt>exodist7@gmail.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

=item Test::Simple

=item Test::More

=item Test::Builder

Originally authored by Michael G Schwern E<lt>schwern@pobox.comE<gt> with much
inspiration from Joshua Pritikin's Test module and lots of help from Barrie
Slaymaker, Tony Bowden, blackstar.co.uk, chromatic, Fergal Daly and the perl-qa
gang.

Idea by Tony Bowden and Paul Johnson, code by Michael G Schwern
E<lt>schwern@pobox.comE<gt>, wardrobe by Calvin Klein.

Copyright 2001-2008 by Michael G Schwern E<lt>schwern@pobox.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

=item Test::use::ok

To the extent possible under law, 唐鳳 has waived all copyright and related
or neighboring rights to L<Test-use-ok>.

This work is published from Taiwan.

L<http://creativecommons.org/publicdomain/zero/1.0>

=item Test::Tester

This module is copyright 2005 Fergal Daly <fergal@esatclear.ie>, some parts
are based on other people's work.

Under the same license as Perl itself

See http://www.perl.com/perl/misc/Artistic.html

=item Test::Builder::Tester

Copyright Mark Fowler E<lt>mark@twoshortplanks.comE<gt> 2002, 2004.

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=back
