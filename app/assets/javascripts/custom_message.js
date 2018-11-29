document.addEventListener("DOMContentLoaded", function() {
  $('#checkall').on('change', function() {
      $('.lineuser_checkbox').prop('checked', this.checked);
  });
});