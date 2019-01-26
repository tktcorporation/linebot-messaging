import Vue from 'vue/dist/vue.esm.js'
import axios from 'axios';

var app = new Vue({
  el: '#app',
  data: function () {
      return {
        lineuser: {name: "", pictureUrl: "", messages: []},
        last_message_id: '',
        newMessage: '',
        bot_id: '',
        lineuser_id: '',
        time: 0
      }
    },
    created: function() {
      setInterval(() => { this.time++ }, 1000);
    },
    watch: {
      time: function(v) {
        if (v % 10 == 0) {
          this.fetchMessages();
        }
      }
    },
    mounted: function () {
      this.set_param();
      this.fetchMessages();
    },
    methods: {
      fetchMessages: function () {
        axios.defaults.headers['X-CSRF-TOKEN'] = $('meta[name=csrf-token]').attr('content')
        axios.get('/api/bot/' + this.bot_id + '/messages/' + this.lineuser_id).then((response) => {
          if (response.data.lineuser.messages.slice(-1)[0].id == this.last_message_id) { return }
          this.last_message_id = response.data.lineuser.messages.slice(-1)[0].id
          this.lineuser.name = response.data.lineuser.name;
          this.lineuser.pictureUrl = response.data.lineuser.pictureUrl;
          this.lineuser.messages = [];
          for(var i = 0; i < response.data.lineuser.messages.length; i++) {
            this.lineuser.messages.push(response.data.lineuser.messages[i]);
          }
        }, (error) => {
          console.log(error);
        });
        this.scroll_bottom();
      },
      set_param: function() {
        var path = window.location.pathname;
        var param_array = path.split('/');
        this.bot_id = param_array[2];
        this.lineuser_id = param_array[4];
      },
      scroll_bottom: function() {
        var obj = document.querySelector(".scroll-message");
        obj.scrollTop = obj.scrollHeight;
      }
    }
})