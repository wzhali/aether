# Aether — OpenWrt 25.12 LuCI Theme
# Repository root Makefile (consumed by the OpenWrt 25.12 SDK).
# Template mirrors the official luci-theme-bootstrap Makefile.

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Aether LuCI Theme (Ultimate Edition)
LUCI_DEPENDS:=+luci-base
LUCI_PKGARCH:=all
LUCI_DESCRIPTION:=A production-grade, enterprise-style LuCI theme for OpenWrt 25.12 \
	with visionOS / Material 3 / Fluent inspired visuals, full design tokens, \
	modular dashboard widgets and complete offline operation.
PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Aether Contributors <noreply@example.com>
PKG_VERSION:=1.0.0

# Where the runtime assets live in the source tree (used by the install rule).
PKG_BUILD_DIR:=$(CURDIR)

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

include ../../luci.mk
# call BuildPackage - OpenWrt buildroot signature