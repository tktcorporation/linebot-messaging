import Vue from 'vue/dist/vue.esm.js'
import axios from 'axios';

var app = new Vue({
  el: '#app',
  data: function () {
    return {
      message: "",
      name: "",
      time: 1,
      isActive: 1,
      formSwitch: 0,
      filename: "image_file",
      bot_id: null,
      lineuser_id: null,
      lineusers: [],
      status_select: 0
    }
  },
  created: function() {
    setInterval(() => { this.time++ }, 30000);
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
    this.setParam();
    this.fetchLineusers();
  },
  filters: {
    truncate: function(value, length) {
      var length = length ? parseInt(length, 10) : 20;

      if(value.length <= length) {
        return value;
      }
      else {
        return value.substring(0, length) + "...";
      }
    }
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
    },
    changeFileName: function(){
      var file = document.getElementById("file");
      if(file.files.length > 0){
        this.filename = file.files[0].name;
      }
    },
    fetchLineusers: function () {
        //axios.defaults.headers['X-CSRF-TOKEN'] = $('meta[name=csrf-token]').attr('content')
        if (this.status_select) {
          axios.get('/api/bot/' + this.bot_id + '/lineusers?status_id=' + this.status_select).then((response) => {
            this.lineusers = response.data.lineusers;
          }, (error) => {
            console.log(error);
          });
        } else {
          axios.get('/api/bot/' + this.bot_id + '/lineusers/').then((response) => {
            this.lineusers = response.data.lineusers;
          }, (error) => {
            console.log(error);
          });
        }
      },
      setParam: function() {
        var path = window.location.pathname;
        var param_array = path.split('/');
        this.bot_id = param_array[2];
        this.lineuser_id = param_array[4];
      },
      debug: function() {
        console.log(this.status_select);
      }
  }
})