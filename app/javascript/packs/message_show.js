import Vue from 'vue/dist/vue.esm.js'
import axios from 'axios';
import messagebox from './components/messagebox.vue'

var app = new Vue({
  el: '#app',
  components: {
    messagebox
  },
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
      statuses: [],
      lineuser: [],
      detailShow: false,
      searchName: ""
    }
  },
  mounted: function () {
    setInterval(() => { this.time++ }, 1000);
    this.fetchLineusers();
    this.fetchLineuser();
  },
  watch: {
    time: function (v) {
      if (v % 120 == 0) {
        this.fetchLineuser();
      }
      if (v % 120 == 0) {
        this.fetchLineusers();
      }
    }
  },
  created: function () {
    this.setParam();
    this.fetchLineusers();
    this.fetchLineuser();
  },
  updated: function () {

  },
  filters: {
    truncate: function (value, length) {
      var length = length ? parseInt(length, 10) : 20;

      if (value.length <= length) {
        return value;
      }
      else {
        return value.substring(0, length) + "...";
      }
    },
    timeFormatter: function (value) {
      var result = /(\d{4})-(\d{2})-(\d{2})T(\d{2}:\d{2})/.exec(value);
      return `${result[2]}-${result[3]} ${result[4]}`
    },
    contentFilter: function (value) {
      switch (value.msg_type) {
        case 0:
          return value.content
        case 1:
          if (value.to_bot == true) {
            return `<a href=/images/${value.id} target=_blank><i class="far fa-image is-size-1 link-text"></i></a>`
          } else {
            var result = /\[画像: (.+)::(.+)\]/.exec(value.content);
            return `<a href=${result[2]} target=_blank><i class="far fa-image is-size-1 link-text"></i></a>`
          }
      }
    }
  },
  methods: {
    switchTab: function (num) {
      this.isActive = num;
    },
    submitAndRedirect: function () {
      this.fetchAndSet();
      document.redirect_form.submit();
    },
    fetchName: function () {
      this.name = document.getElementById("name").value;
    },
    fetchAndSet: function () {
      this.fetchMessage();
      this.fetchName();
      this.setMessageAndName();
    },
    submitStatus: function () {
      document.status_form.submit();
    },
    switchForm: function (num) {
      this.formSwitch = num;
    },
    changeFileName: function () {
      var file = document.getElementById("file");
      if (file.files.length > 0) {
        this.filename = file.files[0].name;
      }
    },
    fetchLineusers: function () {
      //axios.defaults.headers['X-CSRF-TOKEN'] = $('meta[name=csrf-token]').attr('content')
      if (this.status_select) {
        var search = this.searchName ? `&name=${this.searchName}` : ""
        axios.get('/api/bot/' + this.bot_id + '/lineusers?status_id=' + this.status_select + search).then((response) => {
          this.lineusers = response.data.lineusers;
          this.statuses = response.data.statuses;
        }, (error) => {
          console.log(error);
        });
      } else {
        var search = this.searchName ? `?name=${this.searchName}` : ""
        axios.get('/api/bot/' + this.bot_id + '/lineusers' + search).then((response) => {
          this.lineusers = response.data.lineusers;
          this.statuses = response.data.statuses;
        }, (error) => {
          console.log(error);
        });
      }
    },
    setParam: function () {
      var path = window.location.pathname;
      var param_array = path.split('/');
      this.bot_id = param_array[2];
      this.lineuser_id = param_array[4];
    },
    debug: function () {
      console.log(this.status_select);
    },
    fetchLineuser: function () {
      axios.get(`/api/bot/${this.bot_id}/lineusers/${this.lineuser_id}`).then((response) => {
        this.lineuser = response.data.lineuser;
      }, (error) => {
        console.log(error);
      });
    },
    scrollMessageBox: function () {
      if (document.getElementsByClassName("scroll-message")[0]) {
        document.getElementsByClassName("scroll-message")[0].scrollTop = document.getElementsByClassName("scroll-message")[0].scrollHeight;
      };
    },
    detailToggle: function () {
      this.detailShow = !this.detailShow;
    },
    setLineuser: function (id) {
      this.lineuser_id = id;
      this.fetchLineuser();
      this.scrollMessageBox();
    },
    sendMessage: function () {
      if (this.message) {
        axios.defaults.headers['X-CSRF-TOKEN'] = document.querySelector('meta[name=csrf-token]').content;
        axios.post(`/bot/${this.bot_id}/chat/${this.lineuser.id}`, {
          message: this.message
        }).then((response) => {
          console.log(response);
          this.message = "";
          this.fetchLineuser();
        }, (error) => {
          console.log(error);
        });
      }
    },
    reloadLineuser: function () {
      setTimeout(this.fetchLineuser, 2000);
    },
    switchCloseLineuser: function () {
      axios.defaults.headers['X-CSRF-TOKEN'] = document.querySelector('meta[name=csrf-token]').content;
      axios.patch(`/api/bot/${this.bot_id}/lineusers/${this.lineuser.id}/switch_close`).then((response) => {
        this.fetchLineuser();
      }, (error) => {
        console.log(error);
      });
    }
  }
})
