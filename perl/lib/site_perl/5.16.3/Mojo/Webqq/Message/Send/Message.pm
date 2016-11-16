package Mojo::Webqq::Message::Send::Message;
use strict;
use Mojo::Base;
use base qw(Mojo::Base Mojo::Webqq::Message::Base);
sub has { Mojo::Base::attr( __PACKAGE__, @_ ) };

has type         => "message";
has msg_class    => "send";
has msg_from     => "none";
has ttl          => 5;
has allow_plugin => 1;
has msg_time     => sub {time};
has [qw(msg_id sender_id receiver_id sender receiver content raw_content cb)];

sub text {
    my $self = shift;
    return $self->content if ref $self->raw_content ne "ARRAY";
    return join "",map{$_->{content}} grep {$_->{type} eq "txt"} @{$self->{raw_content}};
}
1;
