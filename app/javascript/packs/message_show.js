import Vue from 'vue/dist/vue.esm.js'
import axios from 'axios';

var app = new Vue({
  el: '#app',
  data: function () {
    return {
      message: "",
      name: "",
      time: 0,
      isActive: 1,
      formSwitch: 0
    }
  },
  created: function() {
    setInterval(() => { this.time++ }, 2000);
  },
  watch: {
    time: function(v) {
      if (v % 10 == 0) {
        if (document.getElementById("message")) {
          this.submitAndRedirect();
        }
      }
    }
  },
  mounted: function () {
  },
  methods: {
    switchTab: function(num) {
      this.isActive = num;
    },
    submitAndRedirect: function(){
      this.fetchAndSet();
      document.redirect_form.submit();
    },
    fetchMessage: function() {
      this.message = document.getElementById("message").value;
    },
    fetchName: function(){
      this.name = document.getElementById("name").value;
    },
    setMessageAndName: function() {
      document.getElementById("redirect_message").value = this.message;
      document.getElementById("redirect_name").value = this.name;
    },
    fetchAndSet: function() {
      this.fetchMessage();
      this.fetchName();
      this.setMessageAndName();
    },
    submitStatus: function(){
      document.status_form.submit();
    },
    switchForm: function(num){
      this.formSwitch = num;
    }
  }
})