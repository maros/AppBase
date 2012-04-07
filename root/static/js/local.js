(function($){
    'use strict';
    
    $.widget("ui.appBaseMessenger", { 
        _init: function() { 
            say('Event: ui.AppBaseMessenger.init');
            var $widget = this;
            $widget.element.fadeIn('fast');
            this._recalcHeight();
            
            this.element.find('.message-close').live('click',function () {
                $widget.close($(this).parent('div'));
                return false;
            });
            
            $(window).bind('resize',function () {
                $widget._recalcHeight();
            });
            
            this.element.children('div:not(.message-sticky)').each(function(){
                $widget.set_timeout($(this));
            });
        },
        _recalcHeight: function($message_div,action) {
            var $content = $('#content');
            var content_top = parseInt($content.css('top'));
            if (action == 'add') {
                content_top = content_top + parseInt($message_div.outerHeight());;
            } else if (action == 'remove') {
                content_top = content_top - parseInt($message_div.outerHeight());;
            } else {
                content_top = this.element.parent().outerHeight() + this.offset;
            }
            $content.css('top', content_top + 'px');
        },
        timeout: 15000,
        offset: 35,
        add: function(message,type,sticky) {
            type = typeof(type) != 'undefined' ? type : 'alert';
            sticky = sticky == false ? false : true;
            say('Event: ui.AppBaseMessenger.add');
            var $message_div = $('<div>').css('display','none');
            var $message_icon = $('<div>').addClass('message-icon').addClass('message-icon-' + type);
            var $message_text = $('<div>').addClass('message-text').append(message);
            
            $message_div.addClass('message_sticky')
            $message_div.append($message_icon,'<a href="#" class="message-close">&nbsp;</a>',$message_text);
            
            this.element.append($message_div);
            if (sticky == false) {
                this.set_timeout($message_div);
            }
            $message_div.fadeIn('slow');
            this._recalcHeight($message_div,'add');
            return false;
        },
        set_timeout: function($message_div) {
            var $widget = this;
            window.setTimeout(function() { $widget.run_timeout($message_div) },this.timeout);
        },
        run_timeout: function($message_div) {
            if ($('body').hasClass('focused')) {
                this.close($message_div);
            } else {
                this.set_timeout($message_div);
            }
        },
        close: function($message_div) {
            say('Event: ui.AppBaseMessenger.close');
            this._recalcHeight($message_div,'remove');
            $message_div.fadeOut('slow');
        }
    });

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
    
    /* Initialize messenger bar */
    $('#message').appBaseMessenger();
})(jQuery);





