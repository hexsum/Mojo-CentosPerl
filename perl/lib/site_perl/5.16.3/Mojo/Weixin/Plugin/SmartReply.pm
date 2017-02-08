package Mojo::Weixin::Plugin::SmartReply;
use POSIX;
my $api = 'http://www.tuling123.com/openapi/api';
my %limit;
my %ban;
my @limit_reply = (
    "对不起，请不要这么频繁的艾特我",
    "对不起，您的艾特次数太多",
    "说这么多话不累么，请休息几分钟",
    "能不能小窗我啊，别吵着大家",
);
sub call{
    my $client = shift;
    my $data   = shift;
    $client->interval(600,sub{
        my $key = strftime("%H:%M",localtime(time-600));
        delete $limit{$key};
    });
    $client->on(receive_message=>sub{
        my($client,$msg) = @_;
        return if not $msg->allow_plugin;
        return if $msg->type !~ /^friend_message|group_message$/;
        return if exists $ban{$msg->sender->id};
        my $sender_nick = $msg->sender->displayname;
        my $user_nick = $msg->receiver->displayname;
        return if $msg->type eq "group_message" and !$msg->is_at;

        $msg->allow_plugin(0);
        if($msg->type eq 'group_message'){
            my $key = POSIX::strftime("%H",localtime(time));
            $limit{$key}{$msg->group->id}{$msg->sender->id}++; 
            my $limit  = $limit{$key}{$msg->group->id}{$msg->sender->id};
            if($limit>=8 and $limit<=9){
                $client->reply_message($msg,"\@$sender_nick " . $limit_reply[int rand($#limit_reply+1)],sub{$_[1]->from("bot")});
                return;
            }   
            if($limit >=10 and $limit <=11){
                $client->reply_message($msg,"\@$sender_nick " . "警告，您艾特过于频繁，即将被列入黑名单，请克制",sub{$_[1]->from("bot")});
                return;
            }
            if($limit > 11){
                $ban{$msg->sender->id} = 1;
                $client->reply_message($msg,"\@$sender_nick " . "您已被列入黑名单，1小时内提问无视",sub{$_[1]->from("bot")});
                $client->timer(3600,sub{delete $ban{$msg->sender->id};});
            }
        } 

        my $input = $msg->content;
        $input=~s/\@\Q$user_nick\E(|"\xe2\x80\x85")(\s+)?|\[[^\[\]]+\]//g;
        return unless $input;

        my $json = {
            "key"       =>  $data->{apikey} || "bbdaba85b5cf47bc80e27cbaee7a77df",
            "userid"    =>  $msg->sender->id,
            "info"      =>  $input,
        };

        $json->{"loc"} = $msg->sender->city if $msg->type eq "group_message" and  $msg->sender->city;
        $client->http_post($api,{json=>1},json=>$json,sub{
            my $json = shift;
            return unless defined $json;
            return if $json->{code}=~/^4000[1-7]$/;
            my $reply;
            if($json->{code} == 100000){
                return unless $json->{text};
                $reply = $json->{text};
            } 
            elsif($json->{code} == 200000){
                $reply = "$json->{text}$json->{url}";
            }
            else{return}
            $reply=~s#<br(\s*/)?>#\n#g;
            eval{$reply= Mojo::Util::html_unescape($reply);};
            $client->warn("html entities unescape fail: $@") if $@;
            $reply  = "\@$sender_nick " . $reply  if $msg->type eq 'group_message' and rand(100)>20;
            $reply = $client->truncate($reply,max_bytes=>500,max_lines=>10) if $msg->type eq 'group_message';        
            $client->reply_message($msg,$reply,sub{$_[1]->from("bot")}) if $reply;
        });

    }); 
}
1;
