import Vue from 'vue/dist/vue.esm.js'

var app = new Vue({
  el: '#app',
  data: {
  },
  methods: {
    switchModal: function() {
      document.getElementsByTagName("html")[0].classList.add("is-clipped")
      document.getElementById("new-form-modal").classList.add("is-active")
    }
  }
})