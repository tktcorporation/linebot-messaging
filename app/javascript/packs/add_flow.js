import Vue from 'vue/dist/vue.esm.js'

var app = new Vue({
  el: '#app',
  data: {
    isActive: 1
  },
  methods: {
    switchTab: function(num) {
      this.isActive = num
    }
  }
})