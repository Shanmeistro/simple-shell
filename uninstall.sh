#!/usr/bin/env bash

while read pkg
do
    brew uninstall "$pkg"
done < macos/packages.txt