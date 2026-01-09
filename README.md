# qBittorrent Themes (Custom Fork)

Forked from: [MahdiMirzadeh/qbittorrent](https://github.com/MahdiMirzadeh/qbittorrent)

## 📝 Changelog

### Fixes & Improvements

#### 1. Linux Compatibility (Case-Sensitivity)
- Fixed an issue where country flags failed to load on Linux filesystems due to case mismatch (e.g., `US` vs `us.svg`).
- Added logic to normalize country codes to lowercase before requesting flag images in `dynamicTable.js`.

#### 2. Asset Restoration
- Restored missing MochaUI assets required for proper layout and loading states:
  - `L.gif`
  - `spinner.gif`
  - `spacer.gif`
- This resolves browser console 404 errors and potential visual glitches.

#### 3. Project Configuration
- Added `.gitignore` to exclude build artifacts (webui/qt archives), generated themes, and system files.

