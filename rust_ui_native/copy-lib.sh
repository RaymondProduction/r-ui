#!/bin/sh
mkdir -p native
ls ~/Library/Developer/Xcode/DerivedData/MacUIBridge-*/Build/Products/Debug/libMacUIBridge.dylib
echo "Copying libMacUIBridge.dylib to native directory..."
cp ~/Library/Developer/Xcode/DerivedData/MacUIBridge-*/Build/Products/Debug/libMacUIBridge.dylib native/
ls native/libMacUIBridge.dylib