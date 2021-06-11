<template>
  <div class="tool-container">
    <md5 height="100%" width="100%" />
  </div>
</template>

<script>
import Md5 from '@/components/Tools/Md5'

export default {
  name: 'JsonTool',
  components: { Md5 }
}
</script>

<style scoped>
.tool-container{
  position: relative;
  width: 100%;
  height: calc(100vh - 84px);
}
</style>
