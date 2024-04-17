#!/bin/bash
exec 3> >(cat)
echo "To Terminal"
echo "To cat" 1>&3
echo "To cat again" 1>&2
exec 3>&-