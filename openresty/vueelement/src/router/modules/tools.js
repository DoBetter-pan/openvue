import Layout from '@/layout'

const toolsRouter = {
  path: '/tools',
  component: Layout,
  redirect: 'noRedirect',
  name: 'Tools',
  meta: {
    title: 'Tools',
    icon: 'el-icon-bell'
  },
  children: [
    {
      path: 'json',
      component: () => import('@/views/tools/json'),
      name: 'JsonTool',
      meta: {
        title: 'Json', noCache: true 
      }
    },
    {
      path: 'md5',
      component: () => import('@/views/tools/md5'),
      name: 'Md5Tool',
      meta: {
        title: 'Md5', noCache: true 
      }
    },
    {
      path: 'stock',
      component: () => import('@/views/tools/stock'),
      name: 'StockTool',
      meta: {
        title: 'Stock' 
      }
    }
  ]
}

export default toolsRouter
