#!/bin/bash
# sudo apt install libgtk-4-dev
gcc -shared -fPIC -o libGtkUIBridge.so ../LinuxUIBridge/gtk_bridge.c `pkg-config --cflags --libs gtk4`
mkdir -p native
mv libGtkUIBridge.so native/libGtkUIBridge.so