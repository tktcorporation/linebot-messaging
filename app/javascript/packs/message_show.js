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
      status_select: 0,
      lineuser: [],
      detailShow: false
    }
  },
  created: function() {
    setInterval(() => { this.time++ }, 3000);
  },
  watch: {
    time: function(v) {
      if (v % 10 == 0) {
        this.fetchLineuser();
        // if (document.getElementById("message")) {
        //   this.submitAndRedirect();
        // }
      }
    }
  },
  created: function () {
    this.setParam();
    this.fetchLineusers();
    this.fetchLineuser();
  },
  updated: function() {
    this.scrollMessageBox();
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
    },
    timeFormatter: function(value) {
      var result = /(\d{4})-(\d{2})-(\d{2})T(\d{2}:\d{2})/.exec(value);
      return `${result[2]}-${result[3]} ${result[4]}`
    },
    contentFilter: function(value) {
      switch (value.msg_type) {
        case 0:
          return value.content
        case 1:
          if (value.to_bot == true) {
            return `<a href=/images/${value.id} target=_blank><i class="far fa-image is-size-1 link-text"></i></a>`
          }else{
            var result = /\[画像: (.+)::(.+)\]/.exec(value.content);
            return `<a href=${result[2]} target=_blank><i class="far fa-image is-size-1 link-text"></i></a>`
          }
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
      },
      fetchLineuser: function () {
        axios.get(`/api/bot/${this.bot_id}/lineusers/${this.lineuser_id}`).then((response) => {
          this.lineuser = response.data.lineuser;
        }, (error) => {
          console.log(error);
        });
      },
      scrollMessageBox: function() {
        if (document.getElementsByClassName("scroll-message")[0]) {
          document.getElementsByClassName("scroll-message")[0].scrollTop = document.getElementsByClassName("scroll-message")[0].scrollHeight;
        };
      },
      detailToggle: function() {
        this.detailShow = !this.detailShow
      }
  }
})