#!/bin/sh
unset LD_LIBRARY_PATH
unset DYLD_LIBRARY_PATH

wine ${@}
