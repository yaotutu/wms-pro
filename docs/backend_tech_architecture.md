# GreaterWMS 后端技术架构文档

## 1. 技术栈概述

### 1.1 核心框架
- **Django 3.1+**
  - 完整的MVC架构
  - 自带ORM、Admin等核心功能
  - 配置见`settings.py`

### 1.2 关键技术
- **Django REST framework**
  - 提供RESTful API支持
  - 序列化、视图集、路由等核心功能
- **drf-spectacular**
  - OpenAPI 3.0文档生成
  - 集成Swagger UI
- **SQLite**
  - 默认开发数据库
  - 可替换为MySQL/PostgreSQL
- **django-cors-headers**
  - 处理跨域请求
  - 生产环境需配置白名单

## 2. 项目结构

```
greaterwms/
├── settings.py         # 项目配置
├── urls.py            # 主路由
├── wsgi.py            # WSGI配置
├── utils/             # 工具模块
│   ├── auth.py        # 认证
│   ├── permission.py  # 权限
│   ├── throttle.py    # 限流
│   └── ...
└── apps/              # 业务应用
    ├── staff/         # 员工管理
    ├── asn/           # 入库管理 
    ├── dn/            # 出库管理
    └── ...
```

## 3. 核心功能实现

### 3.1 认证机制
```python
# utils/auth.py
class Authtication:
    def authenticate(self, request):
        token = request.META.get('HTTP_TOKEN')
        if Users.objects.filter(openid=token).exists():
            return (True, user)
        raise APIException("Invalid Token")
```

### 3.2 限流机制
```python
# utils/throttle.py
class VisitThrottle(BaseThrottle):
    def allow_request(self, request, view):
        ip = get_client_ip(request)
        if request.method == 'GET':
            count = get_request_count(ip)
            return count < settings.GET_THROTTLE
```

### 3.3 API设计
- 遵循RESTful规范
- 使用DRF视图集(ViewSets)
- 分页/过滤/搜索支持
- 响应格式统一

## 4. 数据库设计

### 4.1 主要模型
- 用户(Users)
- 商品(Goods)
- 库存(Stock)
- 入库单(ASN)
- 出库单(DN)

### 4.2 关系示例
```python
class ASN(models.Model):
    asn_code = models.CharField(max_length=100)
    supplier = models.ForeignKey(Supplier)
    goods = models.ManyToManyField(Goods)
```

## 5. 性能优化

1. **缓存策略**
   - 高频查询缓存
   - 列表页缓存

2. **数据库优化**
   - 索引优化
   - 查询优化

3. **异步任务**
   - 报表生成
   - 数据导入

4. **监控告警**
   - 错误日志
   - 性能监控

## 6. 部署架构

```
                  ┌───────────────┐
                  │    Nginx      │
                  └──────┬───────┘
                         │
                  ┌──────▼───────┐
                  │   Gunicorn   │
                  └──────┬───────┘
                         │
                  ┌──────▼───────┐
                  │   Django     │
                  └──────┬───────┘
                         │
                  ┌──────▼───────┐
                  │  PostgreSQL  │
                  └──────────────┘
```

## 7. API文档

- 访问 `/api/docs/`
- 包含所有接口定义
- 支持在线测试