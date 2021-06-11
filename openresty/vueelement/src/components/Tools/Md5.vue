<template>
  <div>
    <textarea v-model="md5Text" placehold="Please input Md5 text" class="tool-left" />
    <textarea v-model="finedMd5Text" placehold="" class="tool-right" />
  </div>
</template>

<script>

import load from './dynamicLoadScript'
const md5js = 'https://cdn.bootcss.com/blueimp-md5/2.10.0/js/md5.js'

export default {
  data() {
    return {
      md5Text: ''
    }
  },
  computed: {
    finedMd5Text: {
      get() {
        if (this.md5Text !== '') {
          return md5(this.md5Text)
        } else {
          return ''
        }
      },
      set(val) {
      }
    }
  },
  mounted() {
    this.init()
  },
  methods: {
    init() {
      // dynamic load tinymce from cdn
      load(md5js, (err) => {
        if (err) {
          console.log('Error: ' + err.message)
          return
        }
        // this.initTinymce()
      })
    }
  }
}
</script>

<style scoped>
.tool-left {
  display: inline-block;
  /* position: relative; */
  /* overflow: auto; */
  float: left;
  width: 50%;
  height: 100%;
  margin: 0;
  padding: 10px 10px 10px 30px;
  border: 1px solid #eee;
  border-width: 1px;
  border-style: solid;
  border-color: -internal-light-dark(rgb(118, 118, 118), rgb(133, 133, 133));
  border-radius: 0;
  border-image: initial;
  resize: none;
  outline: none;
  background: #b3d4fc;
  background-color: #fff;
  vertical-align: top;

  cursor: text;
  color: #222;
  min-height: 100vh;
  line-height: 1.53846154;
  letter-spacing: normal;
  word-spacing: normal;
  appearance: auto;
  text-transform: none;
  text-indent: 0px;
  text-shadow: none;
  text-align: start;
  text-rendering: auto;
  text-shadow: none;
  --height: calc(1vh / 3);
  --width: calc(1vw / 3);
  --target: calc(var(--height) + var(--width));
  font: 400 13.3333px Arial;
  font-size: calc(var(--target) + 6px);
  font-family: menlo,monospace, Tahoma,"微软雅黑","幼圆";
}

.tool-right {
  display: inline-block;
  /* position: relative; */
  /* overflow: auto; */
  float: right;
  width: 50%;
  height: 100%;
  margin: 0;
  padding: 10px 10px 10px 30px;
  border: 1px solid #eee;
  border-width: 1px;
  border-style: solid;
  border-color: -internal-light-dark(rgb(118, 118, 118), rgb(133, 133, 133));
  border-radius: 0;
  border-image: initial;
  resize: none;
  outline: none;
  background: #b3d4fc;
  background-color: #fff;
  vertical-align: top;

  cursor: text;
  color: #222;
  min-height: 100vh;
  line-height: 1.53846154;
  letter-spacing: normal;
  word-spacing: normal;
  appearance: auto;
  text-transform: none;
  text-indent: 0px;
  text-shadow: none;
  text-align: start;
  text-rendering: auto;
  text-shadow: none;
  --height: calc(1vh / 3);
  --width: calc(1vw / 3);
  --target: calc(var(--height) + var(--width));
  font: 400 13.3333px Arial;
  font-size: calc(var(--target) + 6px);
  font-family: menlo,monospace, Tahoma,"微软雅黑","幼圆";
}
</style>
