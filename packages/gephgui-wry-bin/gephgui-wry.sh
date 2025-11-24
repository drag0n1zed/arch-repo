#!/bin/sh
#
# Wrapper script for Geph GUI to fix Wayland compatibility issues.
#

export WEBKIT_DISABLE_COMPOSITING_MODE=1
exec /usr/bin/gephgui-wry "$@"
