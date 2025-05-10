# GreaterWMS 前端技术架构文档

## 1. 技术栈详解

### 1.1 核心框架
- **Quasar v1.15.23** 
  - 基于Vue.js的企业级UI框架
  - 提供丰富的Material Design组件
  - 内置RTL支持、国际化、动画等特性
  - 配置见`quasar.conf.js`

### 1.2 关键技术
- **Vue 2.x** 
  - 使用Composition API增强代码组织
  - 核心特性：响应式数据、组件系统、虚拟DOM
- **Vuex** 
  - 状态管理模式
  - 模块化设计(fabchange, bardata, scanedsolve)
- **Axios v0.21.2**
  - 多实例配置(普通请求、认证请求、文件下载)
  - 拦截器统一处理错误和加载状态
- **Dexie v3.0.3**
  - IndexedDB封装库
  - 定义数据模型见`src/db/schema.js`
- **ECharts v5.2.1**
  - 通过`vue-echarts-v3`集成
  - 用于仪表盘数据可视化

## 2. 关键实现细节

### 2.1 API请求处理
```javascript
// 认证请求拦截器示例
axiosInstanceAuth.interceptors.request.use(config => {
  config.headers.token = LocalStorage.getItem('openid')
  config.headers.operator = LocalStorage.getItem('login_id')
  config.headers.language = lang
  return config
})

// 统一错误处理
const errorHandler = (error) => {
  const status = error.response.status
  const message = i18n.t(`notice.${status}`)
  Notify.create({ message, color: 'negative' })
}
```

### 2.2 路由懒加载
```javascript
{
  path: 'goodslist',
  component: () => import('pages/goods/goodslist.vue') // 动态导入
}
```

### 2.3 状态管理
```javascript
// store模块示例 (src/store/bardata)
export default {
  state: {
    title: 'GreaterWMS'
  },
  mutations: {
    SET_TITLE(state, payload) {
      state.title = payload
    }
  }
}
```

### 2.4 本地数据库
```javascript
// src/db/database.js
const db = new Dexie('GreaterWMS')
db.version(1).stores({
  cache: '++id, key, value, expire'
})
```

## 3. 架构图

```
┌─────────────────────────────────────────────────┐
│                    MainLayout                   │
│ ┌─────────────┐  ┌───────────────────────────┐ │
│ │   Sidebar   │  │                           │ │
│ │             │  │        RouterView         │ │
│ │ - Dashboard │  │                           │ │
│ │ - Inbound   │  │ - 动态加载页面组件         │ │
│ │ - Outbound  │  │ - 保持布局结构             │ │
│ └─────────────┘  └───────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

## 4. 性能优化策略

1. **代码分割**
   - 路由级动态导入
   - 第三方库按需加载

2. **缓存策略**
   - IndexedDB缓存API响应
   - 本地存储用户偏好设置

3. **渲染优化**
   - 虚拟滚动长列表
   - 计算属性缓存

4. **打包优化**
   - 配置见`quasar.conf.js`
   - 启用Gzip压缩
   - 图片资源压缩

## 5. 依赖清单

主要生产依赖：
- @quasar/cli: ^1.2.1
- axios: ^0.21.2  
- dexie: ^3.0.3
- echarts: ^5.2.1
- vue-i18n: ^8.24.4

开发依赖：
- @quasar/app: ^2.2.10
- eslint: ^6.8.0
- webpack: ^5.56.0