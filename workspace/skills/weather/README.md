# Weather Search Script - 使用说明

## ✅ 正确的使用方法

### PowerShell 语法规则

**⚠️ 重要：PowerShell 不支持 `&&` 运算符！**

### ✅ 正确示例

```powershell
# 方法 1: 使用参数名
.\search_weather.ps1 -weatherLocation "Tokyo"

# 方法 2: 位置参数
.\search_weather.ps1 "Tokyo"

# 方法 3: 多个命令（使用分号，不是 &&）
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "Tokyo"
```

### ❌ 错误示例（不要使用）

```powershell
# ❌ 错误：PowerShell 不支持 &&
.\search_weather.ps1 $weatherLocation="Tokyo" && echo "Done"

# ❌ 错误：参数语法错误
.\search_weather.ps1 $weatherLocation="Tokyo"
```

## 功能说明

- 搜索指定地点的天气信息
- 使用本地 SearXNG 搜索引擎（端口 18888）
- 自动在浏览器中打开搜索结果

## 使用示例

```powershell
# 搜索东京天气
.\search_weather.ps1 "Tokyo"

# 搜索纽约天气
.\search_weather.ps1 "New York"

# 搜索伦敦天气
.\search_weather.ps1 "London"
```

## 故障排查

如果脚本无法运行：

1. **检查 SearXNG 是否运行**:
   ```powershell
   docker ps --filter "name=searxng"
   ```

2. **检查端口是否正确**:
   - 默认端口: 18888
   - 如果不同，修改脚本中的 `$SEARXNG_URL`

3. **如果浏览器没有自动打开**:
   - 手动复制脚本输出的 URL
   - 在浏览器中访问该 URL

## PowerShell 语法提醒

**永远记住：**
- ❌ **不要使用** `&&`
- ✅ **使用** `;` 或换行分隔命令
- ✅ **使用** `-parameter "value"` 格式传递参数
