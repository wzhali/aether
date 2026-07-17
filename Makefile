# Aether — OpenWrt 25.12 LuCI Theme
# Repository root Makefile (consumed by the OpenWrt 25.12 SDK).
#
# Layout note:
#   The theme source tree keeps its files under luci/{htdocs,luasrc,uci-defaults}
#   so the repo stays self-describing, but OpenWrt's stock `Build/Prepare`
#   only copies the top-level htdocs/luasrc/ucode/root/src directories.
#   We therefore override `Build/Prepare` to mirror our `luci/` subtree into
#   the layout the install rule (and the OpenWrt conventions) expect.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-theme-aether
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Aether Contributors <noreply@example.com>

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

# Mirror our `luci/...` source tree into the layout that OpenWrt's
# default `Build/Prepare` would have used if files lived at the top level.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(TAR) -cf - -C . luci | $(TAR) -xf - -C $(PKG_BUILD_DIR)
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