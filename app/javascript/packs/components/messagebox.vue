<template>
  <!-- <div>{{lineuser.messages}}</div> -->
  <div>
    <div class="message-box" v-for="message in lineuser.messages" :key="message">
      <div v-bind:class="message.to_bot ? 'user-side' : 'bot-side'">
        <img class="lineuser-icon" v-bind:src="lineuser.pictureUrl" v-if="message.to_bot">
        <div
          class="message"
          v-bind:class="message.to_bot ? '' : 'float-right'"
          v-html="$options.filters.contentFilter(message)"
        ></div>
        <span
          class="is-size-7"
          v-bind:class="message.to_bot ? '' : 'float-right bot-message-time'"
        >{{ message.created_at| timeFormatter()}}</span>
      </div>
    </div>
  </div>
  <!-- <div class="form">
      <div v-if="formSwitch == 0">
        <textarea
          class="input message-input"
          name="message"
          id="message"
          placeholder="メッセージ"
          required="required"
          v-model="message"
        ></textarea>
        <div class="inline-block">
          <div>
            <button class="button is-info submit-message" name="button" v-on:click="sendMessage()">
              <i class="far fa-paper-plane"></i>
            </button>
            <div>
              <button class="button" type="button" v-on:click="switchForm(1)">
                <i class="fas fa-plus"></i>
              </button>
            </div>
          </div>
        </div>
      </div>
      <div v-if="formSwitch == 1">
        <div class="columns is-multiline is-mobile">
          <div class="column is-one-quarter">
            <button class="button is-size-4" v-on:click="switchForm(0)">
              <i class="far fa-comment"></i>
            </button>
          </div>
          <div class="column is-one-quarter">
            <button class="button is-size-4" v-on:click="switchForm(2)">
              <i class="far fa-envelope"></i>
            </button>
            <button class="button is-size-4" v-on:click="switchForm(3)">
              <i class="far fa-image"></i>
            </button>
          </div>
          <div class="column is-one-quarter">
            <button class="button is-size-4" v-on:click="switchForm(4)">
              <i class="fas fa-upload"></i>
            </button>
          </div>
        </div>
      </div>
      <div v-if="formSwitch == 2">
        <button class="button float-right" v-on:click="switchForm(0)">
          <i class="far fa-comment"></i>
        </button>
        <form
          data-parsley-validate
          method="post"
          data-remote="true"
          v-bind:action="`/bot/${bot_id}/chat/${lineuser.id}/push_flex`"
          @submit="reloadLineuser"
        >
          <input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">
          <div class="select"></div>
        </form>
      </div>
      <div v-if="formSwitch == 4">
        <button class="button float-right" v-on:click="switchForm(0)">
          <i class="far fa-comment"></i>
        </button>
        <form
          data-parsley-validate
          method="post"
          data-remote="true"
          enctype="multipart/form-data"
          v-bind:action="`/bot/${bot_id}/set_images`"
          @submit="reloadLineuser"
        >
          <input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">
          <input type="hidden" name="lineuser[id]" v-bind:value="lineuser.id">
          <div class="file has-name">
            <label class="file-label">
              <span class="file-cta">
                <span class="file-icon">
                  <i class="fas fa-upload"></i>
                </span>
                <span class="file-label">Choose a file…</span>
              </span>
              <span class="file-name" id="filename">filename}}</span>
            </label>
          </div>
        </form>
      </div>
    </div>
  </div>-->
</template>
<script>
import Vue from "vue/dist/vue.esm.js";
export default {
  props: ["lineuser"],
  filters: {
    truncate: function(value, length) {
      var length = length ? parseInt(length, 10) : 20;

      if (value.length <= length) {
        return value;
      } else {
        return value.substring(0, length) + "...";
      }
    },
    timeFormatter: function(value) {
      var result = /(\d{4})-(\d{2})-(\d{2})T(\d{2}:\d{2})/.exec(value);
      return `${result[2]}-${result[3]} ${result[4]}`;
    },
    contentFilter: function(value) {
      switch (value.msg_type) {
        case 0:
          return value.content;
        case 1:
          if (value.to_bot == true) {
            return `<a href=/images/${
              value.id
            } target=_blank><i class="far fa-image is-size-1 link-text"></i></a>`;
          } else {
            var result = /\[画像: (.+)::(.+)\]/.exec(value.content);
            return `<a href=${
              result[2]
            } target=_blank><i class="far fa-image is-size-1 link-text"></i></a>`;
          }
      }
    }
  }
};
</script>
