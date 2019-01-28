document.addEventListener("DOMContentLoaded", function() {
    Parsley.options.trigger = "keyup focusout change input";

    setTimeout(function() {
        $('.flash').fadeOut();
    }, 9000);

    $('tbody tr[data-href]').addClass('clickable').click(function() {
        window.location = $(this).attr('data-href');
    }).find('a').hover(function() {
        $(this).parents('tr').unbind('click');
    }, function() {
        $(this).parents('tr').click(function() {
            window.location = $(this).attr('data-href');
        });
    });

    $('.signup-button').click(function() {
        var target = $(this).data("target");
        $("html").addClass("is-clipped");
        $('#signup-modal').addClass('is-active');
    });

    $('.new-bot-button').click(function() {
        var target = $(this).data("target");
        $("html").addClass("is-clipped");
        $('#new-bot-modal').toggleClass('is-active');
    });

    $('.new-remind-button').click(function() {
        var target = $(this).data("target");
        $("html").addClass("is-clipped");
        $('#new-remind-modal').toggleClass('is-active');
    });

    $('.modal-background').click(function() {
        $(".modal").removeClass("is-active");
        $("html").removeClass("is-clipped");
    });

    $(".modal-close").click(function() {
        $(".modal").removeClass("is-active");
        $("html").removeClass("is-clipped");
    });
    if ($(".scroll-message")[0]) {
        $(".scroll-message").scrollTop($(".scroll-message")[0].scrollHeight);
    };

    if ($(".burger")[0]) {
        burger = document.querySelector('.burger');
        menu = document.querySelector('#' + burger.dataset.target);
        burger.addEventListener('click', function() {
            burger.classList.toggle('is-active');
            menu.classList.toggle('is-active');
        });
        $(function() {
            $("#scroll_bottom").click(function() {
                $('html, body').animate({
                    scrollTop: $(document).height()
                }, 1000);
                return false;
            });
        });
    }

});