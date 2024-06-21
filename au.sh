#!/bin/bash

# Определить букву диска
disk=$(lsblk -po "model,name" | grep -e HARD | cut -d'/' -f3)
