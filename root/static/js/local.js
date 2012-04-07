

(function($){
    var recalcHeight = function() {
        var header_height = $('header').outerHeight() + 25;
        
        $('#content').animate({
            top: header_height
        },'slow');
    };
    
    var addMessage = function(message,type,sticky) {
        type = typeof(type) != 'undefined' ? type : 'alert';
        sticky = sticky == false ? false : true;
        
        say('Action: message.add');
        
        var $message_div = $('<div>').css('display','none');
        var $message_icon = $('<div>').addClass('message-icon').addClass('message-icon-' + type);
        var $message_text = $('<div>').addClass('message-text').append(message);
        
        $message_div.addClass('message_sticky')
        $message_div.append($message_icon,'<a href="#" class="message-close">&nbsp;</a>',$message_text);
        
        if (sticky == false
            && $('body').hasClass('focused')) {
            window.setTimeout(function() { 
                $message_div.find('message-close').trigger('click');
            },15000);
        }
        
        $('#message').append($message_div);
        $message_div.slideDown('slow',recalcHeight);
    };
    
    /* Initialize main menu */
    $('#navigation-main > ul > li > a').click(function(){
        $('.navigation-selected').removeClass('navigation-selected');
        $(this).parent('li').addClass('navigation-selected');
        var url = $(this).attr('href');
        if (url && url != '#') {
            return true;
        } else {
            return false;
        }
    });
    
    /* Initialize settings menu */
    $('.navigation-user-menu').click(function(){
        say('Event: menu.click');
        return false;
    });
    
    /* Close message handler */
    $('#message .message-close').live('click',function(){
        say('Event: message.close');
        $(this).parent('div').slideUp('slow',recalcHeight);
        return false;
    });
    
    /* Display hidden messages */
    $('#message > DIV').slideDown('slow',recalcHeight);
    
    /* Close non-sticky messages */
    if ($('body').hasClass('focused')) {
        $('#message > div').each(function(){
            var $message = $(this);
            window.setTimeout(function() {
                $message.find('message-close').trigger('click');
            },15000);
        });
    }
})(jQuery);



