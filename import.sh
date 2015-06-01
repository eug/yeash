#!/bin/bash


# This script is just a proof of concept that enables to load particular
# functions and modules in a clean fashion way. This script has a restriction
# that all public functions must depend only by private functions or
# commands that can be found at the PATH or some other environment variable.


# Loads all private functions of a given module
# $1 module name
__load_private_functions()
{
  sed -n "/^__[A-Za-z0-9_]+()/,/^}/p" "${1}.sh" 
}


# Loads a public function of a particular module
# $1 module name
# $2 function name
__load_public_functions()
{
  sed -n "/^${2}()$/,/^}/p" "${1}.sh"
}


__isloaded()
{
  echo "declare -F $1 > /dev/null; echo $?"
}


__err()
{
  echo "$@" 1>&2;
  exit;
}


# usage: use <module>.[function][ as <alias>]
# $1 name of the module/function to include
# $2 the 'as' "keyword"
# $3 function alias
import()
{
  local __arg__=(${1//./ })
  local __mdl__="${__arg__[0]}"
  local __fnc__="${__arg__[1]}"
  local __als__="$3"


  # have specified a function name?
  if [ -n "$__fnc__" ]; then

    local pvt_func="$(__load_private_functions $__mdl__)"
    local tgt_func="$(__load_public_functions  $__mdl__ $__fnc__)"

    # have define an alias?
    if [ "$2" = "as" -a -n "$__als__" ]; then
      tgt_func="${tgt_func//$__fnc__/$__als__}"
    fi

    eval "$pvt_func"
    eval "$tgt_func"

    if [ "$(__isloaded $__fnc__)" = "$(__isloaded $__als__)" ]; then
      __err "unable to load function: $__fnc__"
    fi
    
  else
    # loads the entire module
    source "${__mdl__}.sh"
  fi
}