# 开发路线图

| 阶段 | 模块 | 状态 |
| --- | --- | --- |
| 0 | 架构 & 路线图 | 完成 |
| 1 | Tokens / Icons / Fonts | 完成 |
| 2 | Base / Layout / Typography | 完成 |
| 3 | Components | 完成 |
| 4 | Dashboard widgets | 完成 |
| 5 | Login / Sidebar / Settings | 完成 |
| 6 | LuCI 注册 / APK / uci-defaults | 完成 |
| 7 | CI / Release / README | 完成 |
| 8 | 自检 | 完成 |

## 模块实施顺序

1. **Tokens → Base → Components → Pages**,自底向上,每个模块完成后做
   一次"对比度 / 可达性 / Reduced Motion"自检,再继续下一模块。
2. **JS 在所有 CSS 完成之后**引入,避免互相阻塞渲染。
3. **LuCI 注册和 APK** 在所有前端资源完成后编写,保证一次性注册即可。

## 风险与对策

- LuCI 25.12 视图层细节仍在演进,本主题仅覆盖公共视图类,不做私有
  视图覆盖。
- 路由器性能:JS 总大小控制在 12KB 内,首屏渲染 < 200ms。
- 字体大小:字体使用 woff2 子集,仅 Inter Regular / Medium / SemiBold 与
  JetBrains Mono Regular,总大小 < 280KB。