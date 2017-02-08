sub Mojo::Webqq::_send_sess_message{
    my($self,$msg) = @_;
    if(not defined $msg->sess_sig){
        $msg->send_status(code=>-5,msg=>"发送失败",info=>'无法获取到sess_sig');
        if(ref $msg->cb eq 'CODE'){
            $msg->cb->(
                $self,
                $msg,
            );
        }
        $self->emit(send_message =>
            $msg,
        );
        return;
    }
    my $callback = sub{
        my $json = shift;
        $msg->parse_send_status_msg( $json );
        if(!$msg->is_success and $msg->ttl > 0){
            $self->debug("消息[ " .$msg->id . " ]发送失败，尝试重新发送，当前TTL: " . $msg->ttl);
            $self->message_queue->put($msg);
            return;
        } 
        else{
            if(ref $msg->cb eq 'CODE'){
                $msg->cb->(
                    $self,
                    $msg,
                );
            }
            $self->emit(send_message =>
                $msg,
            );
        }
    };

    my $api_url = ($self->security?'https':'http') . '://d1.web2.qq.com/channel/send_sess_msg2';
    my $headers = {
        Referer => 'http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2',
        json    => 1,
    };
    my @content  = map {
        if($_->{type} eq "txt"){$_->{content}}
        elsif($_->{type} eq "face"){["face",0+$_->{id}]}
    } @{$msg->raw_content};
    #for(my $i=0;$i<@content;$i++){
    #    if(ref $content[$i] eq "ARRAY"){
    #        if(ref $content[$i] eq "ARRAY"){
    #            splice @content,$i+1,0," ";
    #        }
    #        else{
    #            $content[$i+1] = " " . $content[$i+1];
    #        }
    #    }
    #}
    my $content = [@content,["font",{name=>"宋体",size=>10,style=>[0,0,0],color=>"000000"}]];
    my %s = (
        to              => $msg->receiver_id ,
        group_sig       => $msg->sess_sig ,
        face            => $self->user->face || 591,
        content         => $self->to_json($content),
        msg_id          => $msg->id,
        service_type    => $msg->via eq "group"?0:1,
        clientid        => $self->clientid,
        psessionid      => $self->psessionid,
    );
    $self->http_post(
        $api_url,
        $headers,
        form=>{r=>$self->to_json(\%s)},
        $callback,
    );
}
1;
