# Aether — OpenWrt 25.12 LuCI Theme (Ultimate Edition)

## 1. 背景与目标

Aether 是一个面向 OpenWrt 25.12 Stable 与最新 LuCI / ucode / rpcd 栈设计的
企业级 LuCI 主题,目标是在保持与 LuCI 现有视图系统 100% 兼容的同时,提供
visionOS / Material 3 / Fluent 风格的现代视觉,显著超越 Argon、Material3、
Aurora、Glass、Proton2025 等社区主题的视觉与体验。

主要目标:

- 与最新 LuCI 主题架构兼容(`/luci-static/<theme>`、`theme.htm`、`cbi/` 视图)。
- 全部使用原生 CSS + 现代 Web 能力,不使用任何外部 CDN、不内联脚本。
- 在低端路由器(单核 MIPS/ARM 64–128MB RAM)上仍然流畅。
- 提供完整的 Design Tokens,亮/暗/高对比三套主题,跟随浏览器 `prefers-color-scheme`。
- 提供完整的 Dashboard widgets(CPU / 内存 / 温度 / 磁盘 / 流量 / WAN /
  网络拓扑 / IPv4 / IPv6 / VPN / 无线 / 客户端 / 存储 / 运行时长 / 更新)。
- 提供主题设置页:主色 / 强调色 / 侧边栏样式 / 圆角 / 紧凑模式 /
  Glass 强度 / 动画速度 / 字体大小 / 模糊 / 透明度 / 壁纸 / 控件开关。

## 2. LuCI 25.12 架构概览

OpenWrt 25.12 上的 LuCI 主题需要遵守以下契约:

- 主题资源放置:`/www/luci-static/<theme>/`,根目录下必须存在 `theme.htm`,
  框架在请求每个页面时由 dispatcher 嵌入,作为整站外壳。
- 主题可附带 `header.htm` / `footer.htm`(可选)用于在每个视图页内注入内容。
- 主题不直接渲染页面 UI,LuCI 视图层通过 `node.js` 渲染出 `body`,
  主题负责:全局 CSS、字体、图标资源、可选 JS、登录页(由 `themes/<theme>/luasrc/sysauth.htm`)。
- 设置主题:`LuCI → System → System → Language and Style`,或在
  `/cgi-bin/luci/admin/system/themes` 中切换。
- 用户主题偏好存储在 uci:`luci.themes=<theme>`,登录页风格由 `luci.main=`
  `login_theme` 影响。
- 25.12 已经全面转向 ucode + rpcd,主题中不应再使用已废弃的 `luci.fs.*`、
  `luci.http.write` 等接口;视图层以 `require"luci.template"` + `render`
  调用为主。
- 主题不再依赖 Bootstrap,LuCI 25.12 默认使用自研的 `.cbi-*` 视图类与
  现代 CSS 变量,本主题在保留 `.cbi-*` 兼容性的同时引入 `:where(.luci)`
  作用域避免污染。

## 3. 现有主题问题分析

| 主题 | 主要问题 |
| --- | --- |
| Bootstrap | 默认 Bootstrap 4,未适配夜间模式,字号与对比度低,无 Glass |
| Argon | 颜色饱和度过高,Gaming 风,卡片层级混乱,无 Design Tokens |
| Material3 | 组件规范严格,但缺少 dashboard widget 体系,圆角不一致 |
| Aurora | 渐变夸张,小屏布局破坏严重,无主题设置页 |
| Glass | 模糊过强影响可读性,JS 多,部分依赖 CDN |
| Proton2025 | 控件过紧,缺少响应式 sidebar,缺乏无障碍 |

Aether 的差异化策略:

- 视觉:中性、克制,主色采用 Apple 系统蓝 `#0A84FF`,强调色采用
  visionOS 紫 `#BF5AF2`,辅以 Material 3 的 Surface 层级。
- 性能:零 JS 启动依赖,仅一个 ~6KB ES2022 模块用于主题切换 / 折叠 /
  仪表盘刷新。
- 可读性:文本对比度 ≥ 4.5:1,所有交互态有 `focus-visible` 描边。
- 可定制:运行时通过 CSS 变量 + LocalStorage 持久化 + uci 回写。

## 4. 设计系统概览

```
Aether
├── Foundation
│   ├── Tokens (CSS Variables)
│   ├── Typography (Inter / SF Pro fallback)
│   ├── Spacing (4 / 8 / 12 / 16 / 24 / 32 / 48)
│   ├── Radius (4 / 8 / 12 / 16 / 24)
│   ├── Shadow (Soft / Elevated / Modal)
│   ├── Motion (150 / 200 / 250ms)
│   └── Iconography (Lucide 24px / 1.75 stroke)
├── Theme
│   ├── Light
│   ├── Dark
│   ├── High Contrast
│   └── Auto (prefers-color-scheme)
├── Components
│   ├── Button / IconButton / FAB
│   ├── Form / Input / Select / Switch / Slider
│   ├── Card / Stat / KPI
│   ├── Table / DataGrid
│   ├── Alert / Toast / Notification
│   ├── Progress / Meter / Sparkline / Chart
│   ├── Tabs / Segmented / Breadcrumb
│   ├── Dropdown / Menu / Command Palette
│   ├── Modal / Drawer / Sheet
│   ├── Navbar / Sidebar / Footer
│   ├── Terminal
│   └── Search / Spotlight
└── Patterns
    ├── Login
    ├── Dashboard
    └── Settings
```

## 5. 仓库目录结构

```
theme-aether-luci/
├── Makefile
├── README.md
├── LICENSE
├── docs/
│   ├── ARCHITECTURE.md
│   ├── ROADMAP.md
│   ├── CHANGELOG.md
│   └── SCREENSHOTS.md
├── .github/
│   └── workflows/
│       ├── build.yml
│       └── release.yml
├── luci/
│   ├── Makefile
│   ├── manifests/
│   │   └── base
│   ├── apk/
│   │   ├── APKBUILD
│   │   └── luci-theme-aether.post-install
│   ├── uci-defaults/
│   │   └── 99-luci-theme-aether
│   ├── htdocs/
│   │   └── luci-static/
│   │       └── aether/
│   │           ├── theme.htm
│   │           ├── header.htm
│   │           ├── footer.htm
│   │           ├── css/
│   │           │   ├── aether.css           # 主入口
│   │           │   ├── tokens.css
│   │           │   ├── base.css
│   │           │   ├── layout.css
│   │           │   ├── components/
│   │           │   │   ├── button.css
│   │           │   │   ├── form.css
│   │           │   │   ├── card.css
│   │           │   │   ├── table.css
│   │           │   │   ├── alert.css
│   │           │   │   ├── progress.css
│   │           │   │   ├── chart.css
│   │           │   │   ├── tabs.css
│   │           │   │   ├── dropdown.css
│   │           │   │   ├── modal.css
│   │           │   │   ├── terminal.css
│   │           │   │   ├── nav.css
│   │           │   │   ├── sidebar.css
│   │           │   │   ├── breadcrumb.css
│   │           │   │   ├── notification.css
│   │           │   │   └── search.css
│   │           │   ├── pages/
│   │           │   │   ├── login.css
│   │           │   │   ├── dashboard.css
│   │           │   │   └── settings.css
│   │           │   └── vendor/
│   │           │       └── cbi-legacy.css  # 兼容 LuCI .cbi-* 视图
│   │           ├── fonts/
│   │           │   ├── Inter-Regular.woff2
│   │           │   ├── Inter-Medium.woff2
│   │           │   ├── Inter-SemiBold.woff2
│   │           │   └── JetBrainsMono-Regular.woff2
│   │           ├── icons/
│   │           │   ├── lucide.svg           # 单文件 sprite
│   │           │   └── README.md
│   │           ├── img/
│   │           │   ├── logo.svg
│   │           │   ├── logo-dark.svg
│   │           │   ├── wallpaper-light.svg
│   │           │   └── wallpaper-dark.svg
│   │           └── js/
│   │               ├── aether.js             # 主 ES 模块
│   │               ├── theme.js
│   │               ├── dashboard.js
│   │               └── nav.js
│   └── luasrc/
│       ├── view/
│       │   └── themes/
│       │       └── aether/
│       │           └── sysauth.htm
│       └── controller/
│           └── aether.lua
└── screenshots/
    ├── login-light.svg
    ├── login-dark.svg
    ├── dashboard-light.svg
    └── dashboard-dark.svg
```

## 6. 开发路线图

1. 完成 Design Tokens(亮/暗/高对比)与图标 sprite。
2. 完成基础 CSS 与布局(排版、间距、容器查询、断点)。
3. 完成所有基础组件 CSS,确保 .cbi-* 兼容。
4. 实现主题 JS:亮/暗/高对比切换、运行时变量、本地持久化。
5. 实现 dashboard widgets:每一个独立组件,模块化加载。
6. 实现登录页 / 侧边栏 / 导航 / Footer / 设置页。
7. 完成 LuCI 注册与 uci-defaults,APK metadata。
8. 完成 GitHub Actions:CI 构建 / Release 自动打包。
9. 编写 README / CHANGELOG / SCREENSHOTS 占位。
10. 自检:对比度、键盘可达性、Reduced Motion、无 JS 时仍可用。

## 7. 自检要点

- 所有交互元素 `:focus-visible` 必须有 ≥ 2px outline。
- 所有文本对比度 ≥ 4.5(大字体 ≥ 3),警示色对应文本经过 darken 计算。
- Reduced Motion:关闭所有非必要过渡。
- 移动端 ≤ 360px 不溢出,关键操作可单击触达。
- 所有 SVG 通过 `<use xlink:href="#icon-xxx">` 引用,不内联脚本。