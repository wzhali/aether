# Aether — OpenWrt 25.12 LuCI Theme
# Repository root Makefile (consumed by the OpenWrt 25.12 SDK).
#
# We deliberately inline the bits of luci.mk we need rather than
# `include $(TOPDIR)/feeds/luci/luci.mk`, because the SDK does not have
# that path before `feeds update` runs and `feeds install` rejects any
# Makefile that fails to parse during its pre-flight dump check.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-theme-aether
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Aether Contributors <noreply@example.com>

# Note: do NOT override PKG_BUILD_DIR — the build system defaults it to
# $(BUILD_DIR)/$(PKG_NAME), and our install rule already uses $(CURDIR)
# to reach the source tree, which is more robust than $(PKG_BUILD_DIR).

include $(INCLUDE_DIR)/package.mk

define Package/luci-theme-aether
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Themes
  TITLE:=Aether LuCI Theme (Ultimate Edition)
  URL:=https://github.com/wzhali/aether
  DEPENDS:=+luci-base
  PKGARCH:=all
endef

define Package/luci-theme-aether/description
A production-grade, enterprise-style LuCI theme for OpenWrt 25.12 with
visionOS / Material 3 / Fluent inspired visuals, full design tokens,
modular dashboard widgets and complete offline operation.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-theme-aether/install
	$(INSTALL_DIR) $(1)/www/luci-static/aether
	cp -r $(PKG_BUILD_DIR)/luci/htdocs/luci-static/aether/. $(1)/www/luci-static/aether/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/themes/aether
	cp -r $(PKG_BUILD_DIR)/luci/luasrc/view/themes/aether/. $(1)/usr/lib/lua/luci/view/themes/aether/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luci/uci-defaults/99-luci-theme-aether $(1)/etc/uci-defaults/
endef

define Package/luci-theme-aether/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || /etc/uci-defaults/99-luci-theme-aether
exit 0
endef

$(eval $(call BuildPackage,luci-theme-aether))