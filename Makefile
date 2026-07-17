# Aether — OpenWrt 25.12 LuCI Theme
# Repository root Makefile.
# Real packaging lives under luci/.

PKG_NAME:=aether
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Aether Contributors <noreply@example.com>
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aether-luci/aether.git

include $(INCLUDE_DIR)/package.mk

define Package/luci-theme-aether
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Themes
  TITLE:=Aether LuCI Theme (Ultimate Edition)
  PKGARCH:=all
  DEPENDS:=+luci-base
endef

define Package/luci-theme-aether/description
A production-grade, enterprise-style LuCI theme for OpenWrt 25.12 with
visionOS / Material 3 / Fluent inspired visuals, full design tokens,
modular dashboard widgets and complete offline operation.
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