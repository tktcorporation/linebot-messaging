import Vue from 'vue/dist/vue.esm.js'

var app = new Vue({
  el: '#app',
  data: {
    notifyActive: 0
  },
  mounted: function () {
    this.set_notify();
  },
  methods: {
    set_notify: function () {
      var input_text = document.getElementById("bot_notify_token_access_token");
      input_text.removeAttribute('required');
      var elements = document.getElementsByName("bot[notify]")
      if (elements[1].checked) {
        input_text.setAttribute('required', 'required');
      }
    }
  }
})

