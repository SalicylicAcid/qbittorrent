# qBittorrent Themes (Custom Fork)

Forked from: [MahdiMirzadeh/qbittorrent](https://github.com/MahdiMirzadeh/qbittorrent)

[中文说明](#-说明-chinese)

## 📝 Changelog & Features

### 1. Compatibility Fixes
- **luci-app-qbittorrent Adaptation**: 
  - Fixed the persistent error: `"The announce port must be between 0 and 65535."` often seen in OpenWrt/LuCI environments.
- **Linux Compatibility (Case-Sensitivity)**: 
  - Fixed an issue where country flags failed to load on Linux filesystems due to case mismatch (e.g., `US` vs `us.svg`).
  - Added logic to normalize country codes to lowercase before requesting flag images.

### 2. UI & Functional Repairs
- **Dark Mode Improvements**:
  - Fixed visibility and styling issues in **Login Page**, **Add Torrent Link Page**, and **Upload Torrent Page** to correctly support dark themes.
- **Asset Restoration**: 
  - Restored missing MochaUI assets (`L.gif`, `spinner.gif`, `spacer.gif`) required for proper layout and loading states.
  - This resolves browser console 404 errors and potential visual glitches.

### 3. Project Configuration
- Be more developer-friendly by adding `.gitignore` and correctly tracking template files.

---

## 🇨🇳 说明 (Chinese)

本分支旨在修复原版主题在特定环境（如 OpenWrt/LuCI）下的兼容性问题，并完善深色模式的细节。

### 主要修复与改进

#### 1. luci-app-qbittorrent 完美适配
- **消除报错**: 彻底解决了在 OpenWrt 环境下常见的 `"The announce port must be between 0 and 65535."` 错误提示。

#### 2. 深色主题 UI 修复
- 对以下关键页面进行了样式和功能修复，使其在深色模式下显示正常且易于使用：
  - **登录页面 (Login Page)**
  - **添加链接页面 (Add Torrent Link)**
  - **上传种子页面 (Upload Torrent)**

#### 3. Linux/系统兼容性
- **大小写敏感修复**: 修复了 Linux 系统下国旗图标因文件名大小写匹配问题（例如 `US` 与 `us.svg`）而无法加载的 Bug。
- **资源找回**: 补全了遗失的 MochaUI 基础资源（`L.gif`, `spinner.gif`, `spacer.gif`），消除了控制台 404 错误和布局抖动。

