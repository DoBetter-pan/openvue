<template>
  <div class="tool-container">
    <json height="100%" width="100%" />
  </div>
</template>

<script>
import Json from '@/components/Tools/Json'

export default {
  name: 'JsonTool',
  components: { Json }
}
</script>

<style scoped>
.tool-container{
  position: relative;
  width: 100%;
  height: calc(100vh - 84px);
}
</style>
