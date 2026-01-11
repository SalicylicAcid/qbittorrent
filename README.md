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

### 4. Mobile & Interaction Fixes
- **Mobile Context Menu**: Fixed "ghost clicks" and stuck menus on touch devices. The menu now correctly closes after selection and handles touch events properly.
- **Resource Cleanup**: Removed references to missing assets (`toolbox-divider.gif`, etc.) to prevent 500/404 errors.

### 5. OpenWrt/qBittorrent-EE Compatibility & UI Fixes
- **Preferences Compatibility**:
  - Validated and hid unsupported configuration fields in Preferences when running with qBittorrent Enhanced Edition (EE) backends, preventing "undefined" values and UI errors.
  - Mapped specific API keys (e.g., `auto_update_trackers_enabled`) to their correct backend equivalents.
- **RSS Downloader UI**:
  - Fixed RSS Rule button icons ("Add Rule", "Delete Rule") by enforcing correct background sizing (`16px`) and positioning to prevent icons from appearing "zoomed in" or missing.

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

#### 4. OpenWrt/qBittorrent-EE 兼容性与 UI 修正
- **偏好设置适配**:
  - 针对 qBittorrent Enhanced Edition (EE) 后端，自动检测并没有效隐藏不支持的配置选项，防止界面出现 "undefined" 或错误值。
  - 修正了 API 字段映射（如 `auto_update_trackers_enabled`），确保设置能正确保存。
- **RSS 下载器 UI**:
  - 修复了 RSS 下载规则按钮（新建/删除规则）的图标显示问题，强制修正了背景图的尺寸 (`16px`) 和位置，解决了图标显示不全或过大的问题。

#### 4. 移动端与交互修复
- **移动端右键菜单**: 修复了触摸设备上的“幽灵点击”和菜单无法关闭的问题。现在菜单在选择后会正确关闭，并优化了触摸事件处理。
- **资源清理**: 移除了对缺失资源（如 `toolbox-divider.gif` 等）的引用，修复了相关的 500/404 错误。

