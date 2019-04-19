import Vue from 'vue/dist/vue.esm.js'

var app = new Vue({
  el: '#app',
  data: {
    search_show: false
  },
  methods: {
    submitStatus: function(id){
      var form_name = "status_form_" + id
      console.log(form_name);
      document.forms[form_name].submit();
    },
    toggleSearch: function() {
      this.search_show = !this.search_show
    }
  }
});