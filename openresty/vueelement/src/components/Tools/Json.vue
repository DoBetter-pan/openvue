<template>
  <div>
    <textarea v-model="jsonText" placehold="Please input Json text" class="tool-left" />
    <textarea v-model="finedJsonText" placehold="" class="tool-right" />
  </div>
</template>

<script>
export default {
  data() {
    return {
      jsonText: ''
    }
  },
  computed: {
    finedJsonText: {
      get() {
        if (this.jsonText !== '') {
          try {
            var jsonObj = JSON.parse(this.jsonText)
            return JSON.stringify(jsonObj, null, 2)
          } catch (err) {
            return err
          }
        } else {
          return ''
        }
      },
      set(val) {
      }
    }
  }
  /*
  methods: {
    finedJsonText() {
      if (this.jsonText !== '') {
        try {
          var jsonObj = JSON.parse(this.jsonText)
          return JSON.stringify(jsonObj, null, 2)
        } catch (err) {
          return err
        }
      } else {
        return ''
      }
    }
  }
  watch: {
    jsonText(val) {
      console.log("helll xxxxxxxxxx")
      // this.finedJsonText = JSON.stringify(val, null, 2)
    }
  }
  */
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
