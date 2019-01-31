import Vue from 'vue/dist/vue.esm.js'

var app = new Vue({
  el: '#app',
  data: {
  },
  methods: {
    submitStatus: function(id){
      var form_name = "status_form_" + id
      console.log(form_name);
      document.forms[form_name].submit();
    }
  }
});