document.addEventListener("DOMContentLoaded", function() {
    $('.new-form-button').click(function() {
        var target = $(this).data("target");
        $("html").addClass("is-clipped");
        $('#new-form-modal').toggleClass('is-active');
    });
    $(function() {
        $('.new-quick-reply-item-button').click(function() {
            $(this).next('form').slideToggle();
        });
    });
    $('.new-quick-reply-button').click(function() {
        var target = $(this).data("target");
        $("html").addClass("is-clipped");
        $('#new-quick-reply-modal').toggleClass('is-active');
    });
});