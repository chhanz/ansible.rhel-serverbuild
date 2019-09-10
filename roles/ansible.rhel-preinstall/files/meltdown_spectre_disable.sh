#!/bin/bash
# meltdown_spectre_disable
grubby --update-kernel=ALL --args="spectre_v2=off nopti"
grubby --info=ALL
