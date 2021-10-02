#!/bin/bash -
##
## othello.sh - main file for CLI_Othello.
## This file contains the contents of CLI_Othello.
##
##  Copyright (C) 2021 Shintaro Fujiwara
##
##  This program is free software; you can redistribute it and/or
##  modify it under the terms of the GNU Lesser General Public
##  License as published by the Free Software Foundation; either
##  version 2.1 of the License, or (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
##  Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public
##  License along with this library; if not, write to the Free Software
##  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
##  02110-1301 USA
##

HUMAN="Transparent"
COMPUTER="Transparent"
ALPHABET=""
NUMBER=""
POSITION=""
SELECTED=""
REMAIN=64
HUMAN_PASS=0 
COMPUTER_PASS=0
PASS_ALL=0
EMERGENCY=1
SAFEST=0
PRIORITY=0
CORNER_PRIORITY=0
LAST_RESORT=0
PROBABLY_BEST=0
AGGRESSIVE_SAVE=0
REPLY=
PS3=

FILE="1.txt"
FILE_KIFU_PRESENT="./data/kifu_present.txt"

AVAILABLE_NO1=("")
AVAILABLE_NO2=("")
AVAILABLE_NO3=("")
AVAILABLE_NO4=("")
AVAILABLE_NO5=("")
AVAILABLE_NO6=("")
AVAILABLE_NO7=("")
AVAILABLE_NO8=("")
AVAILABLE_NO1_ALL=("")
AVAILABLE_NO2_ALL=("")
AVAILABLE_NO3_ALL=("")
AVAILABLE_NO4_ALL=("")
AVAILABLE_NO5_ALL=("")
AVAILABLE_NO6_ALL=("")
AVAILABLE_NO7_ALL=("")
AVAILABLE_NO8_ALL=("")
FLIPPABLE_NO1=("")
FLIPPABLE_NO2=("")
FLIPPABLE_NO3=("")
FLIPPABLE_NO4=("")
FLIPPABLE_NO5=("")
FLIPPABLE_NO6=("")
FLIPPABLE_NO7=("")
FLIPPABLE_NO8=("")
FLIPPABLE_NO1_ALL=("")
FLIPPABLE_NO2_ALL=("")
FLIPPABLE_NO3_ALL=("")
FLIPPABLE_NO4_ALL=("")
FLIPPABLE_NO5_ALL=("")
FLIPPABLE_NO6_ALL=("")
FLIPPABLE_NO7_ALL=("")
FLIPPABLE_NO8_ALL=("")

## This function checks if the file exists.
## Only two files needed and only one line each.
##

function check_file()
{
    if [ ! -e "${FILE}" ]; then
        echo "File ${FILE} does not exist." >&2
        echo "  a  b  c  d  e  f  g  h" >&2
        exit 1
    fi
    if [ ! -e "${FILE_KIFU_PRESENT}" ]; then
        echo "File ${FILE_KIFU_PRESENT} does not exist." >&2
        echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - W B - - - - - - B W - - - - - - - - - - - - - - - - - - - - - - - - - - -" >&2
        exit 1
    fi
}

## This function shows present kifu
##

function show_kifu_present()
{
    echo "  a  b  c  d  e  f  g  h"
    str_kifu=$(cat "${FILE_KIFU_PRESENT}")
    echo "${str_kifu}" | awk -F" " '{printf"1 "}{for(i=1;i<=8;i++){printf("%s  ",$i)}printf"\n"}'
    echo "${str_kifu}" | awk -F" " '{printf"2 "}{for(i=9;i<=16;i++){printf("%s  ",$i)}printf"\n"}'
    echo "${str_kifu}" | awk -F" " '{printf"3 "}{for(i=17;i<=24;i++){printf("%s  ",$i)}printf"\n"}'
    echo "${str_kifu}" | awk -F" " '{printf"4 "}{for(i=25;i<=32;i++){printf("%s  ",$i)}printf"\n"}'
    echo "${str_kifu}" | awk -F" " '{printf"5 "}{for(i=33;i<=40;i++){printf("%s  ",$i)}printf"\n"}'
    echo "${str_kifu}" | awk -F" " '{printf"6 "}{for(i=41;i<=48;i++){printf("%s  ",$i)}printf"\n"}'
    echo "${str_kifu}" | awk -F" " '{printf"7 "}{for(i=49;i<=56;i++){printf("%s  ",$i)}printf"\n"}'
    echo "${str_kifu}" | awk -F" " '{printf"8 "}{for(i=57;i<=64;i++){printf("%s  ",$i)}printf"\n"}'
}

## This function ensures the strings are alphabet and number both in the range. 
## Sets 'ALPHABET' and 'NUMBER'.

function word_order_check()
{
    local wc=""
    local alphabet=""
    local number=""
    local first_letter=""
    wc="${1}"
    if [ -z "${wc}" ]; then
        echo "Please give string as a variable." >&2
        echo "Ex. a1" >&2
        exit 1
    fi
    first_letter=$(echo "${wc}" | sed -e 's/.$//g')
    second_letter=$(echo "${wc}" | sed -e 's/^.//g')
    if [[ "${first_letter}" =~ [abcdefgh] ]]; then
        ALPHABET="${first_letter}"
        if [[ "${second_letter}" =~ [12345678] ]]; then
            NUMBER="${second_letter}"
            return 0
        else
            echo "Ex. a1" >&2
            return 1
        fi
    else
        echo "Ex. a1" >&2
        return 1
    fi
}

## This function ensures the strings has a-h and 1-8. 
##

function word_check()
{
    local wc=""
    wc="${1}"
    if [ -z "${wc}" ]; then
        echo "Please give string as a variable." >&2
        echo "Ex. a1" >&2
        exit 1
    fi
    if ([[ "${wc}" =~ [abcdefgh] ]] && [[ "${wc}" =~ [12345678] ]]); then
        return 0
    else
        return 1 
    fi
}

## This function ensures the string has 2 letters
##

function word_count()
{
    local wc=""
    wc="${1}"
    if [ -z "${wc}" ]; then
        echo "Please give string as a variable." >&2
        echo "Ex. a1" >&2
        exit 1
    fi
    wc=$(echo "${wc}" | wc -m)
    # wc counts plus 1 so...
    wc=$((wc - 1))
    if ([ $wc -gt 2 ] || [ $wc -lt 2 ]); then
        echo "A letter and a number. Ex. a1." >&2
        return 1
    fi
    return 0
}


## THis function asks question.
##

function question()
{
    echo -n "Position[Ex. a1]:"
    read POSITION 
    if [ -z "${POSITION}" ]; then
        echo "Please give position as a variable." >&2
        echo "Ex. a1" >&2
        question
    fi
}

## THis function gets the position user set.
## Sets 'POSITION'.
##

function get_position()
{
    local num_l=0
    local position=0
    question
    word_count "${POSITION}"
    if [ $? -eq 1 ]; then
        question
    fi
    word_check "${POSITION}"
    if [ $? -eq 1 ]; then
        question
    fi
    word_order_check "${POSITION}"
    if [ $? -eq 1 ]; then
        question
    fi
    if [ "${ALPHABET}" = "a" ]; then
        num_l=1
    elif [ "${ALPHABET}" = "b" ]; then
        num_l=2
    elif [ "${ALPHABET}" = "c" ]; then
        num_l=3
    elif [ "${ALPHABET}" = "d" ]; then
        num_l=4
    elif [ "${ALPHABET}" = "e" ]; then
        num_l=5
    elif [ "${ALPHABET}" = "f" ]; then
        num_l=6
    elif [ "${ALPHABET}" = "g" ]; then
        num_l=7
    elif [ "${ALPHABET}" = "h" ]; then
        num_l=8
    fi
    NUMBER=$((NUMBER - 1))
    NUMBER=$((NUMBER * 8))
    POSITION=$((NUMBER + num_l))
}

## THis function gets the position value.
##

function get_position_value()
{
    local position=0
    get_position
    #echo "POSITION:$POSITION"
}

## Search left
## var1: number
## var2: color 
##

function search1()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as color B,W." >&2
        exit 1
    fi
    # This is needed
    AVAILABLE_NO1=("")
    FLIPPABLE_NO1=("")
    local position="${1}"
    local position_chk=${position}
    local file="${FILE_KIFU_PRESENT}"
    local position_calc=$((position % 8))
    local loop=0
    local _available=0
    if [ $position_calc -eq 0 ]; then
        position_calc=8;
    fi
    local color="${2}"
    local _check_str=""
    # First check the number itself.
    _check_str=$(cut -f "${position}" -d" " "${file}")
    if [ "${_check_str}" != "-" ]; then
        return 1
    fi
    # Here we deduce 1 and find if the position is available, if so set flippable array.
    while [ $position_calc -gt 1 ]
    do
        loop=$((loop + 1)) 
        position_chk_rim=$((position_chk % 8))
        if [ $position_chk_rim -eq 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO1=("")
                FLIPPABLE_NO1=("")
                break
            fi
        fi
        position_chk=$((position_chk - 1)) 
        position_calc=$((position_calc - 1)) 
        if [ $position_chk -lt 1 ]; then
            AVAILABLE_NO1=("")
            FLIPPABLE_NO1=("")
            break
        fi
        _check_str=$(cut -f ${position_chk} -d" " "${file}")
        if ([ "${_check_str}" = "${color}" ] && [ $loop -eq 1 ]); then
            break
        fi
        if [ "${_check_str}" = "-" ]; then
            AVAILABLE_NO1=("")
            FLIPPABLE_NO1=("")
            break
        fi
        if [ "${_check_str}" = "${color}" ]; then
            AVAILABLE_NO1_ALL+=("${AVAILABLE_NO1[*]}")
            FLIPPABLE_NO1_ALL+=("${FLIPPABLE_NO1[*]}")
            break
        fi
        if [ $_available -ne 1 ]; then
            AVAILABLE_NO1+=("#${position}:${position}#")
            _available=1
        fi
        FLIPPABLE_NO1+=("#${position}:${position_chk}#")
        if [ $position_calc -eq 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO1=("")
                FLIPPABLE_NO1=("")
            fi
        fi
    done
    return 0
}

## Search diagonally left-upper
## var1: number
## var2: color 
##

function search2()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as color B,W." >&2
        exit 1
    fi
    # This is needed
    AVAILABLE_NO2=("")
    FLIPPABLE_NO2=("")
    local position="${1}"
    local position_calc=${position}
    local position_calc_rim=${position}
    local file="${FILE_KIFU_PRESENT}"
    local loop=1
    local _available=0
    local color="${2}"
    local _check_str=""
    # First check the number itself.
    _check_str=$(cut -f "${position}" -d" " "${file}")
    if [ "${_check_str}" != "-" ]; then
        return 1
    fi
    # Here we deduce 9 and find if the position is available, if so set flippable array.
    while [ $position_calc -ge 1 ]
    do
        if ([ $position_calc -eq 1 ] || [ $position_calc -eq 8 ] || [ $position_calc -eq 57 ]); then
            AVAILABLE_NO2=("")
            FLIPPABLE_NO2=("")
            break
        fi
        if ([ $position_calc -gt 1 ] && [ $position_calc -lt 8 ]); then
            if [ $_check_str != "${color}" ]; then
                AVAILABLE_NO2=("")
                FLIPPABLE_NO2=("")
                break
            fi
        fi
        position_calc_rim=$((position_calc % 8))
        if [ $position_calc_rim -eq 1 ]; then
            AVAILABLE_NO2=("")
            FLIPPABLE_NO2=("")
            break
        fi
        position_calc=$((position_calc - 9)) 
        loop=$((loop + 1)) 
        if [ $position_calc -lt 1 ]; then
            AVAILABLE_NO2=("")
            FLIPPABLE_NO2=("")
            break
        fi
        if ([ $position_calc -ge 57 ] && [ $position_calc -le 64 ]); then
            AVAILABLE_NO2=("")
            FLIPPABLE_NO2=("")
            break
        fi
        _check_str=$(cut -f ${position_calc} -d" " "${file}")
        if [ "${_check_str}" = "-" ]; then
            AVAILABLE_NO2=("")
            FLIPPABLE_NO2=("")
            break
        fi
        if ([ "${_check_str}" = "${color}" ] && [ $loop -eq 1 ]); then
            break
        fi
        if [ "${_check_str}" = "${color}" ]; then
            AVAILABLE_NO2_ALL+=("${AVAILABLE_NO2[*]}")
            FLIPPABLE_NO2_ALL+=("${FLIPPABLE_NO2[*]}")
            break
        fi
        if [ $_available -ne 1 ]; then
            AVAILABLE_NO2+=("#${position}:${position}#")
            _available=1
        fi
        FLIPPABLE_NO2+=("#${position}:${position_calc}#")
        if [ $position_calc -lt 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO2=("")
                FLIPPABLE_NO2=("")
            fi
        fi
    done
    return 0
}

## Search upper
## var1: number
## var2: color 
##

function search3()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as color B,W." >&2
        exit 1
    fi
    # This is needed
    AVAILABLE_NO3=("")
    FLIPPABLE_NO3=("")
    local position="${1}"
    local position_calc=${position}
    local file="${FILE_KIFU_PRESENT}"
    local loop=1
    local _available=0
    local color="${2}"
    local _check_str=""
    # First check the number itself.
    _check_str=$(cut -f "${position}" -d" " "${file}")
    if [ "${_check_str}" != "-" ]; then
        return 1
    fi
    return_no=1
    # Here we deduce 8 and find if the position is available, if so set flippable array.
    while [ $position_calc -gt 1 ]
    do
        position_calc=$((position_calc - 8)) 
        loop=$((loop + 1)) 
        if [ $position_calc -lt 1 ]; then
            AVAILABLE_NO3=("")
            FLIPPABLE_NO3=("")
            break
        fi
        _check_str=$(cut -f ${position_calc} -d" " "${file}")
        if ([ "${_check_str}" = "${color}" ] && [ $loop -eq 1 ]); then
            break
        fi
        if [ "${_check_str}" = "-" ]; then
            AVAILABLE_NO3=("")
            FLIPPABLE_NO3=("")
            break
        fi
        if [ $position_calc -eq 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO3=("")
                FLIPPABLE_NO3=("")
                break
            fi
        fi
        if [ "${_check_str}" = "${color}" ]; then
            AVAILABLE_NO3_ALL+=("${AVAILABLE_NO3[*]}")
            FLIPPABLE_NO3_ALL+=("${FLIPPABLE_NO3[*]}")
            break
        fi
        if [ $_available -ne 1 ]; then
            AVAILABLE_NO3+=("#${position}:${position}#")
            _available=1
        fi
        FLIPPABLE_NO3+=("#${position}:${position_calc}#")
        if [ $position_calc -lt 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO3=("")
                FLIPPABLE_NO3=("")
            fi
        fi
    done
    return 0
}

## Search diagonally right-upper
## var1: number
## var2: color 
##

function search4()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as color B,W." >&2
        exit 1
    fi
    # This is needed
    AVAILABLE_NO4=("")
    FLIPPABLE_NO4=("")
    local position="${1}"
    local position_calc=${position}
    local position_rim=${position}
    local file="${FILE_KIFU_PRESENT}"
    local loop=1
    local _available=0
    local color="${2}"
    local _check_str=""
    # First check the number itself.
    _check_str=$(cut -f "${position}" -d" " "${file}")
    if [ "${_check_str}" != "-" ]; then
        return 1
    fi
    # Here we deduce 7 and find if the position is available, if so set flippable array.
    while [ $position_calc -gt 1 ]
    do
        if ([ $position -eq 1 ] || [ $position -eq 8 ] || [ $position -eq 64 ]); then
            AVAILABLE_NO4=("")
            FLIPPABLE_NO4=("")
            break
        fi
        if ([ $position -ge 1 ] && [ $position -le 8 ]); then
            AVAILABLE_NO4=("")
            FLIPPABLE_NO4=("")
            break
        fi
        position_calc_rim=$((position_calc % 8))
        if [ $position_calc_rim -eq 0 ]; then
            AVAILABLE_NO4=("")
            FLIPPABLE_NO4=("")
            break
        fi
        position_calc=$((position_calc - 7)) 
        loop=$((loop + 1)) 
        if [ $position_calc -lt 1 ]; then
            AVAILABLE_NO4=("")
            FLIPPABLE_NO4=("")
            break
        fi
        _check_str=$(cut -f ${position_calc} -d" " "${file}")
        if [ "${_check_str}" = "-" ]; then
            AVAILABLE_NO4=("")
            FLIPPABLE_NO4=("")
            break
        fi
        if ([ $position_calc -ge 1 ] && [ $position_calc -le 8 ]); then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO4=("")
                FLIPPABLE_NO4=("")
                break
            fi
        fi
        if ([ "${_check_str}" = "${color}" ] && [ $loop -eq 1 ]); then
            break
        fi
        if [ "${_check_str}" = "${color}" ]; then
            AVAILABLE_NO4_ALL+=("${AVAILABLE_NO4[*]}")
            FLIPPABLE_NO4_ALL+=("${FLIPPABLE_NO4[*]}")
            break
        fi
        if [ $_available -ne 1 ]; then
            AVAILABLE_NO4+=("#${position}:${position}#")
            _available=1
        fi
        FLIPPABLE_NO4+=("#${position}:${position_calc}#")
        if [ $position_calc -lt 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO4=("")
                FLIPPABLE_NO4=("")
            fi
        fi
    done
    return 0
}

## Search right 
## var1: number
## var2: color 
##

function search5()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as color B,W." >&2
        exit 1
    fi
    # This is needed
    AVAILABLE_NO5=("")
    FLIPPABLE_NO5=("")
    local position="${1}"
    local position_chk=${position}
    local file="${FILE_KIFU_PRESENT}"
    local position_calc=$((position % 8))
    local loop=0
    local _available=0
    if [ $position_calc -eq 0 ]; then
        position_calc=8;
    fi
    local color="${2}"
    local _check_str=""
    # First check the number itself.
    _check_str=$(cut -f "${position}" -d" " "${file}")
    if [ "${_check_str}" != "-" ]; then
        return 1
    fi
    same_color=0
    # Here we add 1 and find if the position is available, if so set flippable array.
    while [ $position_calc -le 8 ]
    do
        loop=$((loop + 1)) 
        position_chk_rim=$((position_chk % 8))
        if [ $position_chk_rim -eq 0 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO5=("")
                FLIPPABLE_NO5=("")
                break
            fi
        fi
        position_calc=$((position_calc + 1)) 
        position_chk=$((position_chk + 1)) 
        if [ $position_chk -lt 1 ]; then
            AVAILABLE_NO5=("")
            FLIPPABLE_NO5=("")
            break
        fi
        _check_str=$(cut -f ${position_chk} -d" " "${file}")
        if ([ "${_check_str}" = "${color}" ] && [ $loop -eq 1 ]); then
            break
        fi
        if [ "${_check_str}" = "-" ]; then
            AVAILABLE_NO5=("")
            FLIPPABLE_NO5=("")
            break
        fi
        if [ "${_check_str}" = "${color}" ]; then
            AVAILABLE_NO5_ALL+=("${AVAILABLE_NO5[*]}")
            FLIPPABLE_NO5_ALL+=("${FLIPPABLE_NO5[*]}")
            break
        fi
        if [ $_available -ne 1 ]; then
            AVAILABLE_NO5+=("#${position}:${position}#")
            _available=1
        fi
        FLIPPABLE_NO5+=("#${position}:${position_chk}#")
        if [ $position_calc -eq 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO5=("")
                FLIPPABLE_NO5=("")
            fi
        fi
    done
    return 0
}

## Search diagonally right-down
## var1: number
## var2: color 
##

function search6()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as color B,W." >&2
        exit 1
    fi
    # This is needed
    AVAILABLE_NO6=("")
    FLIPPABLE_NO6=("")
    local position="${1}"
    local position_calc=${position}
    local position_calc_rim=${position}
    local file="${FILE_KIFU_PRESENT}"
    local loop=1
    local _available=0
    local color="${2}"
    local _check_str=""
    # First check the number itself.
    _check_str=$(cut -f "${position}" -d" " "${file}")
    if [ "${_check_str}" != "-" ]; then
        return 1
    fi
    return_no=1
    # Here we add 9 and find if the position is available, if so set flippable array.
    while [ $position_calc -lt 64 ]
    do
        if ([ $position -eq 8 ] || [ $position -eq 57 ] || [ $position -eq 64 ]); then
            AVAILABLE_NO6=("")
            FLIPPABLE_NO6=("")
            break
        fi
        position_calc_rim=$((position_calc % 8))
        if [ $position_calc_rim -eq 0 ]; then
            AVAILABLE_NO6=("")
            FLIPPABLE_NO6=("")
            break
        fi
        position_calc=$((position_calc + 9)) 
        loop=$((loop + 1)) 
        if ([ $position_calc -ge 1 ] && [ $position_calc -le 8 ]); then
            AVAILABLE_NO6=("")
            FLIPPABLE_NO6=("")
            break
        fi
        _check_str=$(cut -f ${position_calc} -d" " "${file}")
        if ([ "${_check_str}" = "${color}" ] && [ $loop -eq 1 ]); then
            break
        fi
        if [ "${_check_str}" = "-" ]; then
            AVAILABLE_NO6=("")
            FLIPPABLE_NO6=("")
            break
        fi
        if [ "${_check_str}" = "${color}" ]; then
            AVAILABLE_NO6_ALL+=("${AVAILABLE_NO6[*]}")
            FLIPPABLE_NO6_ALL+=("${FLIPPABLE_NO6[*]}")
            break
        fi
        if ([ $position_calc -ge 57 ] && [ $position_calc -le 64 ]); then
            AVAILABLE_NO6=("")
            FLIPPABLE_NO6=("")
            break
        fi
        if [ $_available -ne 1 ]; then
            AVAILABLE_NO6+=("#${position}:${position}#")
            _available=1
        fi
        FLIPPABLE_NO6+=("#${position}:${position_calc}#")
        if [ $position_calc -lt 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO6=(" ")
                FLIPPABLE_NO6=("")
            fi
        fi
    done
    return 0
}

## Search down 
## var1: number
## var2: color 
##

function search7()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as color B,W." >&2
        exit 1
    fi
    # This is needed
    AVAILABLE_NO7=("")
    FLIPPABLE_NO7=("")
    local position="${1}"
    local position_calc=${position}
    local file="${FILE_KIFU_PRESENT}"
    local loop=1
    local _available=0
    local color="${2}"
    local _check_str=""
    # First check the number itself.
    _check_str=$(cut -f "${position}" -d" " "${file}")
    if [ "${_check_str}" != "-" ]; then
        return 1
    fi
    # Here we add 8 and find if the position is available, if so set flippable array.
    #while [ $position_calc -lt 64 ]
    while [ $position_calc -le 64 ]
    do
        position_calc=$((position_calc + 8)) 
        loop=$((loop + 1)) 
        if [ $position_calc -gt 64 ]; then
            AVAILABLE_NO7=("")
            FLIPPABLE_NO7=("")
            break
        fi
        _check_str=$(cut -f ${position_calc} -d" " "${file}")
        if ([ "${_check_str}" = "${color}" ] && [ $loop -eq 1 ]); then
            break
        fi
        if [ $position_calc -eq 64 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO7=("")
                FLIPPABLE_NO7=("")
                break
            fi
        fi
        if [ "${_check_str}" = "-" ]; then
            AVAILABLE_NO7=("")
            FLIPPABLE_NO7=("")
            break
        fi
        if [ "${_check_str}" = "${color}" ]; then
            AVAILABLE_NO7_ALL+=("${AVAILABLE_NO7[*]}")
            FLIPPABLE_NO7_ALL+=("${FLIPPABLE_NO7[*]}")
            break
        fi
        if [ $_available -ne 1 ]; then
            AVAILABLE_NO7+=("#${position}:${position}#")
            _available=1
        fi
        FLIPPABLE_NO7+=("#${position}:${position_calc}#")
        if [ $position_calc -lt 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO7=("")
                FLIPPABLE_NO7=("")
            fi
        fi
    done
    return 0
}

## Search diagonally left-down
## var1: number
## var2: color 
##

function search8()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as color B,W." >&2
        exit 1
    fi
    # This is needed
    AVAILABLE_NO8=("")
    FLIPPABLE_NO8=("")
    local position="${1}"
    local position_calc=${position}
    local position_calc_rim=${position}
    local file="${FILE_KIFU_PRESENT}"
    local loop=1
    local _available=0
    local color="${2}"
    local _check_str=""
    # First check the number itself.
    _check_str=$(cut -f "${position}" -d" " "${file}")
    if [ "${_check_str}" != "-" ]; then
        return 1
    fi
    # Here we add 7 and find if the position is available, if so set flippable array.
    while [ $position_calc -lt 64 ]
    do
        if ([ $position -eq 1 ] || [ $position -eq 57 ] || [ $position -eq 64 ]); then
            AVAILABLE_NO8=("")
            FLIPPABLE_NO8=("")
            break
        fi
        position_calc_rim=$((position_calc % 8))
        if [ $position_calc_rim -eq 1 ]; then
            AVAILABLE_NO8=("")
            FLIPPABLE_NO8=("")
            break
        fi
        position_calc=$((position_calc + 7)) 
        loop=$((loop + 1)) 
	if ([ $position_calc -ge 1 ] && [ $position_calc -le 8 ]); then
            AVAILABLE_NO8=("")
            FLIPPABLE_NO8=("")
            break
        fi
        _check_str=$(cut -f ${position_calc} -d" " "${file}")
        if ([ "${_check_str}" = "${color}" ] && [ $loop -eq 1 ]); then
            break
        fi
        if [ "${_check_str}" = "-" ]; then
            AVAILABLE_NO8=("")
            FLIPPABLE_NO8=("")
            break
        fi
        if [ "${_check_str}" = "${color}" ]; then
            AVAILABLE_NO8_ALL+=("${AVAILABLE_NO8[*]}")
            FLIPPABLE_NO8_ALL+=("${FLIPPABLE_NO8[*]}")
            break
        fi
        if ([ $position_calc -ge 57 ] && [ $position_calc -le 64 ]); then
            AVAILABLE_NO8=("")
            FLIPPABLE_NO8=("")
            break
        fi
        if [ $_available -ne 1 ]; then
            AVAILABLE_NO8+=("#${position}:${position}#")
            _available=1
        fi
        FLIPPABLE_NO8+=("#${position}:${position_calc}#")
        if [ $position_calc -lt 1 ]; then
            if [ "${_check_str}" != "${color}" ]; then
                AVAILABLE_NO8=("")
                FLIPPABLE_NO8=("")
            fi
        fi
    done
    return 0
}

## This function searches available positions.
##

function search_available_positions()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a color." >&2
        exit 1
    fi
    local teban=${1}
    local file="${FILE_KIFU_PRESENT}"
    local _str=""
    local _check_str=""
    local color=""
    local i=1

    if [ "${teban}" = "White" ]; then
        color="W"
    elif [ "${teban}" = "Black" ]; then
        color="B"
    fi

    AVAILABLE_ALL=("")
    FLIPPABLE_ALL=("")

    AVAILABLE_NO1_ALL=("")
    AVAILABLE_NO2_ALL=("")
    AVAILABLE_NO3_ALL=("")
    AVAILABLE_NO4_ALL=("")
    AVAILABLE_NO5_ALL=("")
    AVAILABLE_NO6_ALL=("")
    AVAILABLE_NO7_ALL=("")
    AVAILABLE_NO8_ALL=("")

    FLIPPABLE_NO1_ALL=("")
    FLIPPABLE_NO2_ALL=("")
    FLIPPABLE_NO3_ALL=("")
    FLIPPABLE_NO4_ALL=("")
    FLIPPABLE_NO5_ALL=("")
    FLIPPABLE_NO6_ALL=("")
    FLIPPABLE_NO7_ALL=("")
    FLIPPABLE_NO8_ALL=("")

    AVAILABLE_NO1=("")
    AVAILABLE_NO2=("")
    AVAILABLE_NO3=("")
    AVAILABLE_NO4=("")
    AVAILABLE_NO5=("")
    AVAILABLE_NO6=("")
    AVAILABLE_NO7=("")
    AVAILABLE_NO8=("")

    FLIPPABLE_NO1=("")
    FLIPPABLE_NO2=("")
    FLIPPABLE_NO3=("")
    FLIPPABLE_NO4=("")
    FLIPPABLE_NO5=("")
    FLIPPABLE_NO6=("")
    FLIPPABLE_NO7=("")
    FLIPPABLE_NO8=("")

    while [ $i -lt 65 ]
    do
        _check_str=$(cut -f $i -d" " "${file}")
        search1 $i "${color}" 
        search2 $i "${color}" 
        search3 $i "${color}" 
        search4 $i "${color}" 
        search5 $i "${color}" 
        search6 $i "${color}" 
        search7 $i "${color}" 
        search8 $i "${color}" 
        i=$((i + 1)) 
    done

    AVAILABLE_ALL+=(${AVAILABLE_NO1_ALL[*]})
    AVAILABLE_ALL+=(${AVAILABLE_NO2_ALL[*]})
    AVAILABLE_ALL+=(${AVAILABLE_NO3_ALL[*]})
    AVAILABLE_ALL+=(${AVAILABLE_NO4_ALL[*]})
    AVAILABLE_ALL+=(${AVAILABLE_NO5_ALL[*]})
    AVAILABLE_ALL+=(${AVAILABLE_NO6_ALL[*]})
    AVAILABLE_ALL+=(${AVAILABLE_NO7_ALL[*]})
    AVAILABLE_ALL+=(${AVAILABLE_NO8_ALL[*]})
    FLIPPABLE_ALL+=(${FLIPPABLE_NO1_ALL[*]})
    FLIPPABLE_ALL+=(${FLIPPABLE_NO2_ALL[*]})
    FLIPPABLE_ALL+=(${FLIPPABLE_NO3_ALL[*]})
    FLIPPABLE_ALL+=(${FLIPPABLE_NO4_ALL[*]})
    FLIPPABLE_ALL+=(${FLIPPABLE_NO5_ALL[*]})
    FLIPPABLE_ALL+=(${FLIPPABLE_NO6_ALL[*]})
    FLIPPABLE_ALL+=(${FLIPPABLE_NO7_ALL[*]})
    FLIPPABLE_ALL+=(${FLIPPABLE_NO8_ALL[*]})

    #echo "AVAILABLE_NO1_ALL,${AVAILABLE_NO1_ALL[*]} FLIPPABLE_NO1_ALL,${FLIPPABLE_NO1_ALL[*]}"
    #echo "AVAILABLE_NO2_ALL,${AVAILABLE_NO2_ALL[*]} FLIPPABLE_NO2_ALL,${FLIPPABLE_NO2_ALL[*]}"
    #echo "AVAILABLE_NO3_ALL,${AVAILABLE_NO3_ALL[*]} FLIPPABLE_NO3_ALL,${FLIPPABLE_NO3_ALL[*]}"
    #echo "AVAILABLE_NO4_ALL,${AVAILABLE_NO4_ALL[*]} FLIPPABLE_NO4_ALL,${FLIPPABLE_NO4_ALL[*]}"
    #echo "AVAILABLE_NO5_ALL,${AVAILABLE_NO5_ALL[*]} FLIPPABLE_NO5_ALL,${FLIPPABLE_NO5_ALL[*]}"
    #echo "AVAILABLE_NO6_ALL,${AVAILABLE_NO6_ALL[*]} FLIPPABLE_NO6_ALL,${FLIPPABLE_NO6_ALL[*]}"
    #echo "AVAILABLE_NO7_ALL,${AVAILABLE_NO7_ALL[*]} FLIPPABLE_NO7_ALL,${FLIPPABLE_NO7_ALL[*]}"
    #echo "AVAILABLE_NO8_ALL,${AVAILABLE_NO8_ALL[*]} FLIPPABLE_NO8_ALL,${FLIPPABLE_NO8_ALL[*]}"
    #echo "AVAILABLE_ALL,${AVAILABLE_ALL[*]} FLIPPABLE_NO8_ALL,${FLIPPABLE_ALL[*]}"
    #echo "Searched available positions."
    if [ -z "${AVAILABLE_ALL[*]}" ]; then
        return 2
    fi
    return 0
}

## This function returns 0 certain number if it's available (including flippable).
## if var2 exists only flippable.
## var1: number
## var2: number_flippable
##

function is_number_available()
{
    local num=0
    local num_flippable=0
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    num="${1}" 
    if [ ! -z "${2}" ]; then
        num_flippable="${2}" 
    fi
    local num_str="" 
    local pat="" 
    # Try to match when only one member and not forget last one.
    if [ $num_flippable -eq 0 ]; then
        pat="#$num:$num#"
        num_str=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " -v pat="${pat}" '{for(i=1;i<=NF;i++) if ($i ~ pat) {printf("%s ",$i)}}')
    else
        pat="#[0-9]+:$num_flippable#"
        num_str=$(echo "${FLIPPABLE_ALL[*]}" | awk -F" " -v pat="${pat}" '{for(i=1;i<=NF;i++) if ($i ~ pat) {printf("%s ",$i)}}')
    fi
    if [ -z "${num_str}" ]; then
        return 1
    fi
    return 0
}

## This function returns 0 certain number if it's occupied.
## var1: number
##

function is_number_occupied()
{
    local file="${FILE_KIFU_PRESENT}"
    local _check_str=""
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    num="${1}" 
    _check_str=$(cut -f $num -d" " "${file}")
    if [ "${_check_str}" != "-" ]; then
        return 0
    fi
    return 1
}

## This function returns 0 if corner is available.
##

function is_corner_available()
{
    local num_1=""
    local num_8=""
    local num_57=""
    local num_64=""
    num_1=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#1:1#") {printf("%s ",$i)}}')
    num_8=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#8:8#") {printf("%s ",$i)}}')
    num_57=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#57:57#") {printf("%s ",$i)}}')
    num_64=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#64:64#") {printf("%s ",$i)}}')
    if ([ -z "${num_1}" ] && [ -z "${num_8}" ] && [ -z "${num_57}" ] && [ -z "${num_64}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-corner is available.
##

function is_sub_corner_available()
{
    local num_19=""
    local num_22=""
    local num_43=""
    local num_46=""
    num_19=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#19:19#") {printf("%s ",$i)}}')
    num_22=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#22:22#") {printf("%s ",$i)}}')
    num_43=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#43:43#") {printf("%s ",$i)}}')
    num_46=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#46:46#") {printf("%s ",$i)}}')
    if ([ -z "${num_19}" ] && [ -z "${num_22}" ] && [ -z "${num_43}" ] && [ -z "${num_46}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if upper rim sub-corner is available.
##

function is_upper_rim_sub_corner_available()
{
    local num_3=""
    local num_6=""
    num_3=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#3:3#") {printf("%s ",$i)}}')
    num_6=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#6:6#") {printf("%s ",$i)}}')
    if ([ -z "${num_3}" ] && [ -z "${num_6}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if right rim sub-corner is available.
##

function is_right_rim_sub_corner_available()
{
    local num_24=""
    local num_48=""
    num_24=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#24:24#") {printf("%s ",$i)}}')
    num_48=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#48:48#") {printf("%s ",$i)}}')
    if ([ -z "${num_24}" ] && [ -z "${num_48}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if down rim sub-corner is available.
##

function is_down_rim_sub_corner_available()
{
    local num_59=""
    local num_62=""
    num_59=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#59:59#") {printf("%s ",$i)}}')
    num_62=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#62:62#") {printf("%s ",$i)}}')
    if ([ -z "${num_59}" ] && [ -z "${num_62}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if left rim sub-corner is available.
##

function is_left_rim_sub_corner_available()
{
    local num_17=""
    local num_41=""
    num_17=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#17:17#") {printf("%s ",$i)}}')
    num_41=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#41:41#") {printf("%s ",$i)}}')
    if ([ -z "${num_17}" ] && [ -z "${num_41}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if upper rim is available.
##

function is_upper_rim_available()
{
    local num_4=""
    local num_5=""
    num_4=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#4:4#") {printf("%s ",$i)}}')
    num_5=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#5:5#") {printf("%s ",$i)}}')
    if ([ -z "${num_4}" ] && [ -z "${num_5}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if right rim is available.
##

function is_right_rim_available()
{
    local num_32=""
    local num_40=""
    num_32=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#32:32#") {printf("%s ",$i)}}')
    num_40=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#40:40#") {printf("%s ",$i)}}')
    if ([ -z "${num_32}" ] && [ -z "${num_40}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if down rim is available.
##

function is_down_rim_available()
{
    local num_60=""
    local num_61=""
    num_60=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#60:60#") {printf("%s ",$i)}}')
    num_61=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#61:61#") {printf("%s ",$i)}}')
    if ([ -z "${num_60}" ] && [ -z "${num_61}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if left rim is available.
##

function is_left_rim_available()
{
    local num_25=""
    local num_33=""
    num_25=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#25:25#") {printf("%s ",$i)}}')
    num_33=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#33:33#") {printf("%s ",$i)}}')
    if ([ -z "${num_25}" ] && [ -z "${num_33}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-upper rim is available.
##

function is_sub_upper_rim_available()
{
    local num_20=""
    local num_21=""
    num_20=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#20:20#") {printf("%s ",$i)}}')
    num_21=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#21:21#") {printf("%s ",$i)}}')
    if ([ -z "${num_20}" ] && [ -z "${num_21}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-right rim is available.
##

function is_sub_right_rim_available()
{
    local num_30=""
    local num_38=""
    num_30=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#30:30#") {printf("%s ",$i)}}')
    num_38=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#38:38#") {printf("%s ",$i)}}')
    if ([ -z "${num_30}" ] && [ -z "${num_38}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-down rim is available.
##

function is_sub_down_rim_available()
{
    local num_44=""
    local num_45=""
    num_44=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#44:44#") {printf("%s ",$i)}}')
    num_45=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#45:45#") {printf("%s ",$i)}}')
    if ([ -z "${num_44}" ] && [ -z "${num_45}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-left rim is available.
##

function is_sub_left_rim_available()
{
    local num_27=""
    local num_35=""
    num_27=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#27:27#") {printf("%s ",$i)}}')
    num_35=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#35:35#") {printf("%s ",$i)}}')
    if ([ -z "${num_27}" ] && [ -z "${num_35}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if upper rim-above is available.
##

function is_upper_rim_above_available()
{
    local num_12=""
    local num_13=""
    num_12=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#12:12#") {printf("%s ",$i)}}')
    num_13=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#13:13#") {printf("%s ",$i)}}')
    if ([ -z "${num_12}" ] && [ -z "${num_13}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if right rim-above is available.
##

function is_right_rim_above_available()
{
    local num_31=""
    local num_39=""
    num_31=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#31:31#") {printf("%s ",$i)}}')
    num_39=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#39:39#") {printf("%s ",$i)}}')
    if ([ -z "${num_31}" ] && [ -z "${num_39}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if down rim-above is available.
##

function is_down_rim_above_available()
{
    local num_52=""
    local num_53=""
    num_52=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#52:52#") {printf("%s ",$i)}}')
    num_53=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#53:53#") {printf("%s ",$i)}}')
    if ([ -z "${num_52}" ] && [ -z "${num_53}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if left rim-above is available.
##

function is_left_rim_above_available()
{
    local num_26=""
    local num_34=""
    num_26=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#26:26#") {printf("%s ",$i)}}')
    num_34=$(echo "${AVAILABLE_ALL[*]}" | awk -F" " '{for(i=1;i<=NF;i++) if ($i ~ "#34:34#") {printf("%s ",$i)}}')
    if ([ -z "${num_26}" ] && [ -z "${num_34}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if opponent exists in rim except corners and it is not flippable.
##

function opponent_exists_in_rim()
{
    #echo "I check if it's safe."
    if [ -z "${1}" ]; then
        echo "Please give a variable as a color." >&2
        exit 1
    fi
    local teban=${1}
    local file="${FILE_KIFU_PRESENT}"
    local color=""
    local color_opponent=""
    local _check_str3=""
    local _check_str4=""
    local _check_str5=""
    local _check_str6=""
    local _check_str17=""
    local _check_str25=""
    local _check_str33=""
    local _check_str41=""
    local _check_str24=""
    local _check_str32=""
    local _check_str40=""
    local _check_str48=""
    local _check_str59=""
    local _check_str60=""
    local _check_str61=""
    local _check_str62=""
    local _str3_flippable=""
    local _str4_flippable=""
    local _str5_flippable=""
    local _str6_flippable=""
    local _str17_flippable=""
    local _str25_flippable=""
    local _str33_flippable=""
    local _str41_flippable=""
    local _str24_flippable=""
    local _str32_flippable=""
    local _str40_flippable=""
    local _str48_flippable=""
    local _str59_flippable=""
    local _str60_flippable=""
    local _str61_flippable=""
    local _str62_flippable=""

    if [ "${teban}" = "White" ]; then
        color="W"
        color_opponent="B"
    elif [ "${teban}" = "Black" ]; then
        color="B"
        color_opponent="W"
    fi
    _check_str3=$(cut -f 3 -d" " "${file}")
    _check_str4=$(cut -f 4 -d" " "${file}")
    _check_str5=$(cut -f 5 -d" " "${file}")
    _check_str6=$(cut -f 6 -d" " "${file}")
    _check_str17=$(cut -f 17 -d" " "${file}")
    _check_str25=$(cut -f 25 -d" " "${file}")
    _check_str33=$(cut -f 33 -d" " "${file}")
    _check_str41=$(cut -f 41 -d" " "${file}")
    _check_str24=$(cut -f 24 -d" " "${file}")
    _check_str32=$(cut -f 32 -d" " "${file}")
    _check_str40=$(cut -f 40 -d" " "${file}")
    _check_str48=$(cut -f 48 -d" " "${file}")
    _check_str59=$(cut -f 59 -d" " "${file}")
    _check_str60=$(cut -f 60 -d" " "${file}")
    _check_str61=$(cut -f 61 -d" " "${file}")
    _check_str62=$(cut -f 62 -d" " "${file}")

    is_number_available 0 3
    if [ $? -eq 0 ]; then
        _str3_flippable="yes"
    fi
    is_number_available 0 4
    if [ $? -eq 0 ]; then
        _str4_flippable="yes"
    fi
    is_number_available 0 5
    if [ $? -eq 0 ]; then
        _str5_flippable="yes"
    fi
    is_number_available 0 6
    if [ $? -eq 0 ]; then
        _str6_flippable="yes"
    fi
    is_number_available 0 17
    if [ $? -eq 0 ]; then
        _str17_flippable="yes"
    fi
    is_number_available 0 25
    if [ $? -eq 0 ]; then
        _str25_flippable="yes"
    fi
    is_number_available 0 33
    if [ $? -eq 0 ]; then
        _str33_flippable="yes"
    fi
    is_number_available 0 41
    if [ $? -eq 0 ]; then
        _str41_flippable="yes"
    fi
    is_number_available 0 24
    if [ $? -eq 0 ]; then
        _str24_flippable="yes"
    fi
    is_number_available 0 40
    if [ $? -eq 0 ]; then
        _str40_flippable="yes"
    fi
    is_number_available 0 48
    if [ $? -eq 0 ]; then
        _str48_flippable="yes"
    fi
    is_number_available 0 59
    if [ $? -eq 0 ]; then
        _str59_flippable="yes"
    fi
    is_number_available 0 60 
    if [ $? -eq 0 ]; then
        _str60_flippable="yes"
    fi
    is_number_available 0 61 
    if [ $? -eq 0 ]; then
        _str61_flippable="yes"
    fi
    is_number_available 0 62
    if [ $? -eq 0 ]; then
        _str62_flippable="yes"
    fi

    if ([ "${_check_str3}" = "${color_opponent}" ] && [ ! -z "${_str3_flippable}" ] ||
            [ "${_check_str4}" = "${color_opponent}" ] && [ ! -z "${_str4_flippable}" ] ||
            [ "${_check_str5}" = "${color_opponent}" ] && [ ! -z "${_str5_flippable}" ] ||
            [ "${_check_str6}" = "${color_opponent}" ] && [ ! -z "${_str6_flippable}" ] ||
            [ "${_check_str17}" = "${color_opponent}" ] && [ ! -z "${_str17_flippable}" ] ||
            [ "${_check_str25}" = "${color_opponent}" ] && [ ! -z "${_str25_flippable}" ] ||
            [ "${_check_str33}" = "${color_opponent}" ] && [ ! -z "${_str33_flippable}" ] ||
            [ "${_check_str41}" = "${color_opponent}" ] && [ ! -z "${_str41_flippable}" ] ||
            [ "${_check_str24}" = "${color_opponent}" ] && [ ! -z "${_str24_flippable}" ] ||
            [ "${_check_str32}" = "${color_opponent}" ] && [ ! -z "${_str32_flippable}" ] ||
            [ "${_check_str40}" = "${color_opponent}" ] && [ ! -z "${_str40_flippable}" ] ||
            [ "${_check_str48}" = "${color_opponent}" ] && [ ! -z "${_str48_flippable}" ] ||
            [ "${_check_str59}" = "${color_opponent}" ] && [ ! -z "${_str59_flippable}" ] ||
            [ "${_check_str60}" = "${color_opponent}" ] && [ ! -z "${_str60_flippable}" ] ||
            [ "${_check_str61}" = "${color_opponent}" ] && [ ! -z "${_str61_flippable}" ] ||
            [ "${_check_str62}" = "${color_opponent}" ] && [ ! -z "${_str62_flippable}" ]); then
        return 0
    fi
    return 1
}

## This function returns 0 if flippable is safe.
## var1: number
## var2: color 
##

function is_flippable_safe()
{
    if [ $REMAIN -eq 0 ]; then
        return 0
    fi
    local num=0
    local str_c=""
    local _chk55=""
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    num="${1}" 
    str_c=$(get_contents_flippables $num)
    _chk10=$(echo "${str_c}" | grep "10#")
    _chk17=$(echo "${str_c}" | grep "15#")
    _chk50=$(echo "${str_c}" | grep "50#")
    _chk55=$(echo "${str_c}" | grep "55#")
    if ([ $num  -eq 3 ] || [ $num -eq 6 ] || [ $num -eq 17 ] || [ $num -eq 24 ] ||
            [ $num  -eq 41 ] || [ $num -eq 47 ] || [ $num -eq 48 ] || [ $num -eq 59 ] ||
            [ $num -eq 62 ]); then
        if ([ ! -z "${_chk10}" ] || [ ! -z "${_chk17}" ] || [ ! -z "${_chk50}" ] || [ ! -z "${_chk55}" ]); then
            echo "$num is not safe!"
            return 1 
        fi
    fi
    return 0 
}

## This function returns 0 if in some numbers are safe and if it's so, return 0.
## var1: number
## var2: color 
##

function is_number_safe()
{
    if [ $REMAIN -eq 0 ]; then
        return 0
    fi
    local num=0
    local teban=""
    local file="${FILE_KIFU_PRESENT}"
    local color=""
    local color_opponent=""
    local _check_str1=""
    local _check_str2=""
    local _check_str3=""
    local _check_str4=""
    local _check_str5=""
    local _check_str6=""
    local _check_str7=""
    local _check_str8=""
    local _check_str9=""
    local _check_str16=""
    local _check_str17=""
    local _check_str24=""
    local _check_str25=""
    local _check_str32=""
    local _check_str33=""
    local _check_str40=""
    local _check_str41=""
    local _check_str48=""
    local _check_str49=""
    local _check_str56=""
    local _check_str57=""
    local _check_str58=""
    local _check_str59=""
    local _check_str60=""
    local _check_str61=""
    local _check_str62=""
    local _check_str63=""
    local _check_str64=""
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    num="${1}" 
    if [ -z "${2}" ]; then
        echo "Please give a variable as a color." >&2
        exit 1
    fi
    teban="${2}"
    if [ "${teban}" = "White" ]; then
        color="W"
        color_opponent="B"
    elif [ "${teban}" = "Black" ]; then
        color="B"
        color_opponent="W"
    fi
    ## pattern 0 ######
    if [ $REMAIN -le 1 ]; then
        return 0
    fi
    ## pattern 1 ######
    if ([ $num -eq 4 ] || [ $num -eq 5 ] || [ $num -eq 60 ] || [ $num -eq 61 ] ||
            [ $num -eq 25 ] || [ $num -eq 33 ] || [ $num -eq 32 ] || [ $num -eq 40 ]); then    
        if [ $num -eq 4 ]; then
            is_number_available 4
            if [ $? -eq 0 ]; then
                _check_str1=$(cut -f 1 -d" " "${file}")
                _check_str2=$(cut -f 2 -d" " "${file}")
                _check_str3=$(cut -f 3 -d" " "${file}")
                _check_str4=$(cut -f 4 -d" " "${file}")
                _check_str5=$(cut -f 5 -d" " "${file}")
                _check_str6=$(cut -f 6 -d" " "${file}")
                _check_str7=$(cut -f 7 -d" " "${file}")
                _check_str8=$(cut -f 8 -d" " "${file}")
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "-" ] &&
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] && [ "${_check_str7}" = "${color}" ] &&
                        [ "${_check_str8}" = "-" ]);then
                    return 1
                fi
                if (([ "${_check_str2}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ] &&
                        [ "${_check_str5}" = "${color_opponent}" ]) ||
                        ([ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && [ "${_check_str7}" = "${color}" ] &&
                        [ "${_check_str3}" = "${color_opponent}" ])); then
                    return 1
                fi
                if [ "${_check_str3}" = "${color_opponent}" ]; then
                    AGGRESSIVE_SAVE=$num
                fi
                return 0
            fi
        fi
        if [ $num -eq 5 ]; then
            is_number_available 5
            if [ $? -eq 0 ]; then
                _check_str1=$(cut -f 1 -d" " "${file}")
                _check_str2=$(cut -f 2 -d" " "${file}")
                _check_str3=$(cut -f 3 -d" " "${file}")
                _check_str4=$(cut -f 4 -d" " "${file}")
                _check_str5=$(cut -f 5 -d" " "${file}")
                _check_str6=$(cut -f 6 -d" " "${file}")
                _check_str7=$(cut -f 7 -d" " "${file}")
                _check_str8=$(cut -f 8 -d" " "${file}")
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && [ "${_check_str6}" = "-" ] && [ "${_check_str5}" = "-" ] &&
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "-" ] && [ "${_check_str2}" = "${color}" ] &&
                        [ "${_check_str1}" = "-" ]);then
                    return 1
                fi
                if (([ "${_check_str6}" = "${color}" ] && [ "${_check_str7}" = "${color}" ] && [ "${_check_str4}" = "${color_opponent}" ]) ||
                        ([ "${_check_str2}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] &&
                        [ "${_check_str6}" = "${color_opponent}" ])); then
                    return 1
                fi
                if [ "${_check_str4}" = "${color_opponent}" ]; then
                    AGGRESSIVE_SAVE=$num
                fi
                return 0
            fi
        fi
        if [ $num -eq 60 ]; then
            is_number_available 60
            if [ $? -eq 0 ]; then
                _check_str57=$(cut -f 57 -d" " "${file}")
                _check_str58=$(cut -f 58 -d" " "${file}")
                _check_str59=$(cut -f 59 -d" " "${file}")
                _check_str60=$(cut -f 60 -d" " "${file}")
                _check_str61=$(cut -f 61 -d" " "${file}")
                _check_str62=$(cut -f 62 -d" " "${file}")
                _check_str63=$(cut -f 63 -d" " "${file}")
                _check_str64=$(cut -f 64 -d" " "${file}")
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "-" ] &&
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "-" ] && [ "${_check_str63}" = "${color}" ] &&
                        [ "${_check_str64}" = "-" ]);then
                    return 1
                fi
                if (([ "${_check_str58}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ] &&
                        [ "${_check_str61}" = "${color_opponent}" ]) ||
                        ([ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && [ "${_check_str63}" = "${color}" ] &&
                        [ "${_check_str59}" = "${color_opponent}" ])); then
                    return 1
                fi
                if [ "${_check_str59}" = "${color_opponent}" ]; then
                    AGGRESSIVE_SAVE=$num
                fi
                return 0
            fi
        fi
        if [ $num -eq 61 ]; then
            is_number_available 61
            if [ $? -eq 0 ]; then
                _check_str57=$(cut -f 57 -d" " "${file}")
                _check_str58=$(cut -f 58 -d" " "${file}")
                _check_str59=$(cut -f 59 -d" " "${file}")
                _check_str60=$(cut -f 60 -d" " "${file}")
                _check_str61=$(cut -f 61 -d" " "${file}")
                _check_str62=$(cut -f 62 -d" " "${file}")
                _check_str63=$(cut -f 63 -d" " "${file}")
                _check_str64=$(cut -f 64 -d" " "${file}")
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && [ "${_check_str62}" = "-" ] && [ "${_check_str61}" = "-" ] &&
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "-" ] && [ "${_check_str58}" = "${color}" ] &&
                        [ "${_check_str57}" = "-" ]);then
                    return 1
                fi
                if (([ "${_check_str62}" = "${color}" ] && [ "${_check_str63}" = "${color}" ] && [ "${_check_str60}" = "${color_opponent}" ]) ||
                        ([ "${_check_str58}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] &&
                        [ "${_check_str62}" = "${color_opponent}" ])); then
                    return 1
                fi
                if [ "${_check_str60}" = "${color_opponent}" ]; then
                    AGGRESSIVE_SAVE=$num
                fi
                return 0
            fi
        fi
        if [ $num -eq 25 ]; then
            is_number_available 25 
            if [ $? -eq 0 ]; then
                _check_str1=$(cut -f 1 -d" " "${file}")
                _check_str9=$(cut -f 9 -d" " "${file}")
                _check_str17=$(cut -f 17 -d" " "${file}")
                _check_str25=$(cut -f 25 -d" " "${file}")
                _check_str33=$(cut -f 33 -d" " "${file}")
                _check_str41=$(cut -f 41 -d" " "${file}")
                _check_str49=$(cut -f 49 -d" " "${file}")
                _check_str57=$(cut -f 57 -d" " "${file}")
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "-" ] &&
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] && [ "${_check_str49}" = "${color}" ] &&
                        [ "${_check_str57}" = "-" ]);then
                    return 1
                fi
                if (([ "${_check_str17}" = "${color}" ] && [ "${_check_str9}" = "${color}" ] && [ "${_check_str33}" = "${color_opponent}" ]) ||
                        ([ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && [ "${_check_str49}" = "${color}" ] &&
                        [ "${_check_str17}" = "${color_opponent}" ])); then
                    return 1
                fi
                if [ "${_check_str17}" = "${color_opponent}" ]; then
                    AGGRESSIVE_SAVE=$num
                fi
                return 0
            fi
        fi
        if [ $num -eq 33 ]; then
            is_number_available  33
            if [ $? -eq 0 ]; then
                _check_str1=$(cut -f 1 -d" " "${file}")
                _check_str9=$(cut -f 9 -d" " "${file}")
                _check_str17=$(cut -f 17 -d" " "${file}")
                _check_str25=$(cut -f 25 -d" " "${file}")
                _check_str33=$(cut -f 33 -d" " "${file}")
                _check_str41=$(cut -f 41 -d" " "${file}")
                _check_str49=$(cut -f 49 -d" " "${file}")
                _check_str57=$(cut -f 57 -d" " "${file}")
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && [ "${_check_str41}" = "-" ] && [ "${_check_str33}" = "-" ] &&
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "-" ] && [ "${_check_str9}" = "${color}" ] &&
                        [ "${_check_str1}" = "-" ]);then
                    return 1
                fi
                if (([ "${_check_str41}" = "${color}" ] && [ "${_check_str49}" = "${color}" ] && [ "${_check_str25}" = "${color_opponent}" ]) ||
                        ([ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color}" ] && [ "${_check_str9}" = "${color}" ] &&
                        [ "${_check_str41}" = "${color_opponent}" ])); then
                    return 1
                fi
                if [ "${_check_str25}" = "${color_opponent}" ]; then
                    AGGRESSIVE_SAVE=$num
                fi
                return 0
            fi
        fi
        if [ $num -eq 32 ]; then
            is_number_available  32
            if [ $? -eq 0 ]; then
                _check_str8=$(cut -f 8 -d" " "${file}")
                _check_str16=$(cut -f 16 -d" " "${file}")
                _check_str24=$(cut -f 24 -d" " "${file}")
                _check_str32=$(cut -f 32 -d" " "${file}")
                _check_str40=$(cut -f 40 -d" " "${file}")
                _check_str48=$(cut -f 48 -d" " "${file}")
                _check_str56=$(cut -f 56 -d" " "${file}")
                _check_str64=$(cut -f 64 -d" " "${file}")
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "-" ] &&
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] && [ "${_check_str56}" = "${color}" ] &&
                        [ "${_check_str64}" = "-" ]);then
                    return 1
                fi
                if (([ "${_check_str24}" = "${color}" ] && [ "${_check_str16}" = "${color}" ] && [ "${_check_str40}" = "${color_opponent}" ]) ||
                        ([ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && [ "${_check_str56}" = "${color}" ] &&
                        [ "${_check_str24}" = "${color_opponent}" ])); then
                    return 1
                fi
                if [ "${_check_str24}" = "${color_opponent}" ]; then
                    AGGRESSIVE_SAVE=$num
                fi
                return 0
            fi
        fi
        if [ $num -eq 40 ]; then
            is_number_available 40 
            if [ $? -eq 0 ]; then
                _check_str8=$(cut -f 8 -d" " "${file}")
                _check_str16=$(cut -f 16 -d" " "${file}")
                _check_str24=$(cut -f 24 -d" " "${file}")
                _check_str32=$(cut -f 32 -d" " "${file}")
                _check_str40=$(cut -f 40 -d" " "${file}")
                _check_str48=$(cut -f 48 -d" " "${file}")
                _check_str56=$(cut -f 56 -d" " "${file}")
                _check_str64=$(cut -f 64 -d" " "${file}")
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "-" ] &&
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "-" ] && [ "${_check_str16}" = "${color}" ] &&
                        [ "${_check_str8}" = "-" ]);then
                    return 1
                fi
                if (([ "${_check_str48}" = "${color}" ] && [ "${_check_str56}" = "${color}" ] && [ "${_check_str32}" = "${color_opponent}" ]) ||
                        ([ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color}" ] && [ "${_check_str16}" = "${color}" ] &&
                        [ "${_check_str48}" = "${color_opponent}" ])); then
                    return 1
                fi
                if [ "${_check_str32}" = "${color_opponent}" ]; then
                    AGGRESSIVE_SAVE=$num
                fi
                return 0
            fi
        fi
    fi
    ## pattern 2 ######
    if ([ $num -eq 41 ] || [ $num -eq 17 ] || [ $num -eq 48 ] || [ $num -eq 24 ] ||
            [ $num -eq 3 ] || [ $num -eq 6 ] || [ $num -eq 59 ] || [ $num -eq 62 ]); then
        if [ $num -eq 41 ]; then
            _check_str57=$(cut -f 57 -d" " "${file}")
            _check_str49=$(cut -f 49 -d" " "${file}")
            _check_str41=$(cut -f 41 -d" " "${file}")
            _check_str33=$(cut -f 33 -d" " "${file}")
            _check_str25=$(cut -f 25 -d" " "${file}")
            _check_str17=$(cut -f 17 -d" " "${file}")
            _check_str9=$(cut -f 9 -d" " "${file}")
            _check_str1=$(cut -f 1 -d" " "${file}")
            _check_flippable=$(get_contents_flippables 41 | grep "50#")
            is_number_available 41
            if [ $? -eq 0 ]; then
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "${color_opponent}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "${color}" ] &&
                        [ "${_check_str41}" = "-" ] && [ "${_check_str33}" = "${color_opponent}" ] &&
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color}" ] &&
                        [ "${_check_str9}" = "${color}" ] && [ "${_check_str1}" = "${color}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "${color}" ] && 
                        [ "${_check_str41}" = "-" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 1
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "${color}" ] && 
                        [ "${_check_str41}" = "-" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                        [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                        [ "${_check_str41}" = "-" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                        [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color}" ] && 
                        [ "${_check_str9}" = "${color}" ] && [ "${_check_str1}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                        [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                        [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                        [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color_opponent}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                        [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                        [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                        [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                        [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                        [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color}" ] && 
                        [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] &&
                        [ "${_check_str17}" = "${color_opponent}" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] &&
                        [ "${_check_str17}" = "${color_opponent}" ] && 
                        [ "${_check_str9}" = "${color}" ] && [ "${_check_str1}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "${color}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] &&
                        [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str25}" = "-" ] && [ "${_check_str33}" = "-" ] &&
                        [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str33}" = "${color}" ] && [ "${_check_str15}" = "${color_opponent}" ] &&
                        [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str15}" = "${color}" ] &&
                        [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color_opponent}" ] &&
                        [ "${_check_str17}" = "${color_opponent}" ] && 
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] &&
                        [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] &&
                        [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "-" ] &&
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] &&
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] &&
                        [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color_opponent}" ] &&
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] &&
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] &&
                        [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color}" ] &&
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] &&
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                return 1
            fi
        fi
        if [ $num -eq 17 ]; then
            _check_str1=$(cut -f 1 -d" " "${file}")
            _check_str9=$(cut -f 9 -d" " "${file}")
            _check_str17=$(cut -f 17 -d" " "${file}")
            _check_str25=$(cut -f 25 -d" " "${file}")
            _check_str33=$(cut -f 33 -d" " "${file}")
            _check_str41=$(cut -f 41 -d" " "${file}")
            _check_str49=$(cut -f 49 -d" " "${file}")
            _check_str57=$(cut -f 57 -d" " "${file}")
            _check_flippable=$(get_contents_flippables 17 | grep "10#")
            is_number_available 17 
            if [ $? -eq 0 ]; then
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color_opponent}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color}" ] &&
                        [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "${color_opponent}" ] &&
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color}" ] &&
                        [ "${_check_str49}" = "${color}" ] && [ "${_check_str57}" = "${color}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color}" ] && 
                        [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 1
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color}" ] && 
                        [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                        [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                        [ "${_check_str49}" = "${color}" ] && [ "${_check_str57}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                        [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                        [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                        [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                        [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "${color_opponent}" ] && 
                        [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "${color_opponent}" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                        [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "${color_opponent}" ] && 
                        [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] && 
                        [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                        [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] && 
                        [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color_opponent}" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] &&
                        [ "${_check_str41}" = "${color_opponent}" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] &&
                        [ "${_check_str41}" = "${color_opponent}" ] && 
                        [ "${_check_str49}" = "${color}" ] && [ "${_check_str57}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color}" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] &&
                        [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str25}" = "-" ] && [ "${_check_str33}" = "-" ] &&
                        [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str25}" = "${color}" ] && [ "${_check_str33}" = "${color_opponent}" ] &&
                        [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color}" ] &&
                        [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "${color_opponent}" ] &&
                        [ "${_check_str41}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] &&
                        [ "${_check_str17}" = "-" ] && 
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] &&
                        [ "${_check_str41}" = "-" ] && [ "${_check_str33}" = "-" ] &&
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "-" ] &&
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] &&
                        [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color_opponent}" ] &&
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "-" ] &&
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] &&
                        [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color}" ] &&
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "-" ] &&
                        [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                return 1
            fi
        fi
        if [ $num -eq 48 ]; then
            _check_str64=$(cut -f 64 -d" " "${file}")
            _check_str56=$(cut -f 56 -d" " "${file}")
            _check_str48=$(cut -f 48 -d" " "${file}")
            _check_str40=$(cut -f 40 -d" " "${file}")
            _check_str32=$(cut -f 32 -d" " "${file}")
            _check_str24=$(cut -f 24 -d" " "${file}")
            _check_str16=$(cut -f 16 -d" " "${file}")
            _check_str8=$(cut -f 8 -d" " "${file}")
            _check_flippable=$(get_contents_flippables 48 | grep "55#")
            is_number_available 48
            if [ $? -eq 0 ]; then
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "${color_opponent}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "${color}" ] &&
                        [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "${color_opponent}" ] &&
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color}" ] &&
                        [ "${_check_str16}" = "${color}" ] && [ "${_check_str8}" = "${color}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "${color}" ] && 
                        [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 1
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "${color}" ] && 
                        [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                        [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                        [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                        [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color}" ] && 
                        [ "${_check_str16}" = "${color}" ] && [ "${_check_str8}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                        [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                        [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                        [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                        [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                        [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                        [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                        [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                        [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color}" ] && 
                        [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] &&
                        [ "${_check_str24}" = "${color_opponent}" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] &&
                        [ "${_check_str24}" = "${color_opponent}" ] && 
                        [ "${_check_str16}" = "${color}" ] && [ "${_check_str8}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "${color}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] &&
                        [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str32}" = "-" ] && [ "${_check_str40}" = "-" ] &&
                        [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str40}" = "${color}" ] && [ "${_check_str32}" = "${color_opponent}" ] &&
                        [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color}" ] &&
                        [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ] &&
                        [ "${_check_str24}" = "${color_opponent}" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] &&
                        [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] &&
                        [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "-" ] &&
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] &&
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] &&
                        [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color_opponent}" ] &&
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] &&
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] &&
                        [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color}" ] &&
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "-" ] &&
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                return 1
            fi
        fi
        if [ $num -eq 24 ]; then
            _check_str8=$(cut -f 8 -d" " "${file}")
            _check_str16=$(cut -f 16 -d" " "${file}")
            _check_str24=$(cut -f 24 -d" " "${file}")
            _check_str32=$(cut -f 32 -d" " "${file}")
            _check_str40=$(cut -f 40 -d" " "${file}")
            _check_str48=$(cut -f 48 -d" " "${file}")
            _check_str56=$(cut -f 56 -d" " "${file}")
            _check_str64=$(cut -f 64 -d" " "${file}")
            _check_flippable=$(get_contents_flippables 24 | grep "15#")
            is_number_available 24 
            if [ $? -eq 0 ]; then
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color}" ] &&
                        [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "${color_opponent}" ] &&
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color}" ] &&
                        [ "${_check_str56}" = "${color}" ] && [ "${_check_str64}" = "${color}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color}" ] && 
                        [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 1
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color}" ] && 
                        [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                        [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                        [ "${_check_str56}" = "${color}" ] && [ "${_check_str64}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                        [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                        [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                        [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                        [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "${color_opponent}" ] && 
                        [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                        [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "${color_opponent}" ] && 
                        [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] && 
                        [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                        [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] && 
                        [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] &&
                        [ "${_check_str48}" = "${color_opponent}" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] &&
                        [ "${_check_str48}" = "${color_opponent}" ] && 
                        [ "${_check_str56}" = "${color}" ] && [ "${_check_str64}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color}" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] &&
                        [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str32}" = "-" ] && [ "${_check_str40}" = "-" ] &&
                        [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str32}" = "${color}" ] && [ "${_check_str40}" = "${color_opponent}" ] &&
                        [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color}" ] &&
                        [ "${_check_str48}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "${color_opponent}" ] &&
                        [ "${_check_str48}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] &&
                        [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] &&
                        [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "-" ] &&
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "-" ] &&
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] &&
                        [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color_opponent}" ] &&
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "-" ] &&
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] &&
                        [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color}" ] &&
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "-" ] &&
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                return 1
            fi
        fi
        if [ $num -eq 3 ]; then
            _check_str1=$(cut -f 1 -d" " "${file}")
            _check_str2=$(cut -f 2 -d" " "${file}")
            _check_str3=$(cut -f 3 -d" " "${file}")
            _check_str4=$(cut -f 4 -d" " "${file}")
            _check_str5=$(cut -f 5 -d" " "${file}")
            _check_str6=$(cut -f 6 -d" " "${file}")
            _check_str7=$(cut -f 7 -d" " "${file}")
            _check_str8=$(cut -f 8 -d" " "${file}")
            _check_flippable=$(get_contents_flippables 3 | grep "10#")
            is_number_available 3 
            if [ $? -eq 0 ]; then
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color}" ] &&
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] &&
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color}" ] &&
                        [ "${_check_str7}" = "${color}" ] && [ "${_check_str8}" = "${color}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color}" ] && 
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 1
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color}" ] && 
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                        [ "${_check_str7}" = "${color}" ] && [ "${_check_str8}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                        [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                        [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "-" ] && 
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                        [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "${color_opponent}" ] && 
                        [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] && 
                        [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && 
                        [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] && 
                        [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] &&
                        [ "${_check_str6}" = "${color_opponent}" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] &&
                        [ "${_check_str6}" = "${color_opponent}" ] && 
                        [ "${_check_str7}" = "${color}" ] && [ "${_check_str8}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color}" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] &&
                        [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str4}" = "-" ] && [ "${_check_str5}" = "-" ] &&
                        [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str4}" = "${color}" ] && [ "${_check_str5}" = "${color_opponent}" ] &&
                        [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color}" ] &&
                        [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "${color_opponent}" ] &&
                        [ "${_check_str6}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] &&
                        [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] &&
                        [ "${_check_str6}" = "-" ] && [ "${_check_str5}" = "-" ] &&
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "-" ] &&
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] &&
                        [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color_opponent}" ] &&
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "-" ] &&
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] &&
                        [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color}" ] &&
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "-" ] &&
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                return 1
            fi
        fi
        if [ $num -eq 6 ]; then
            _check_str1=$(cut -f 1 -d" " "${file}")
            _check_str2=$(cut -f 2 -d" " "${file}")
            _check_str3=$(cut -f 3 -d" " "${file}")
            _check_str4=$(cut -f 4 -d" " "${file}")
            _check_str5=$(cut -f 5 -d" " "${file}")
            _check_str6=$(cut -f 6 -d" " "${file}")
            _check_str7=$(cut -f 7 -d" " "${file}")
            _check_str8=$(cut -f 8 -d" " "${file}")
            _check_flippable=$(get_contents_flippables 6 | grep "15#")
            is_number_available 6 
            if [ $? -eq 0 ]; then
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "${color_opponent}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "${color}" ] &&
                        [ "${_check_str6}" = "-" ] && [ "${_check_str5}" = "${color_opponent}" ] &&
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color}" ] &&
                        [ "${_check_str2}" = "${color}" ] && [ "${_check_str1}" = "${color}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "${color}" ] && 
                        [ "${_check_str6}" = "-" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 1
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "${color}" ] && 
                        [ "${_check_str6}" = "-" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                        [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && 
                        [ "${_check_str6}" = "-" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                        [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && 
                        [ "${_check_str2}" = "${color}" ] && [ "${_check_str1}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                        [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                        [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                        [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                        [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                        [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                        [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                        [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                        [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] &&
                        [ "${_check_str3}" = "${color_opponent}" ] && 
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] &&
                        [ "${_check_str3}" = "${color_opponent}" ] && 
                        [ "${_check_str2}" = "${color}" ] && [ "${_check_str1}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "${color}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] &&
                        [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str4}" = "-" ] && [ "${_check_str5}" = "-" ] &&
                        [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str5}" = "${color}" ] && [ "${_check_str4}" = "${color_opponent}" ] &&
                        [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color}" ] &&
                        [ "${_check_str3}" = "-" ] && 
                        [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ] &&
                        [ "${_check_str3}" = "${color_opponent}" ] && 
                        [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] &&
                        [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] &&
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "-" ] &&
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] &&
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] &&
                        [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color_opponent}" ] &&
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] &&
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] &&
                        [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color}" ] &&
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] &&
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                    return 0
                fi
                return 1
            fi
        fi
        if [ $num -eq 59 ]; then
            _check_str57=$(cut -f 57 -d" " "${file}")
            _check_str58=$(cut -f 58 -d" " "${file}")
            _check_str59=$(cut -f 59 -d" " "${file}")
            _check_str60=$(cut -f 60 -d" " "${file}")
            _check_str61=$(cut -f 61 -d" " "${file}")
            _check_str62=$(cut -f 62 -d" " "${file}")
            _check_str63=$(cut -f 63 -d" " "${file}")
            _check_str64=$(cut -f 64 -d" " "${file}")
            _check_flippable=$(get_contents_flippables 59 | grep "50#")
            is_number_available 59 
            if [ $? -eq 0 ]; then
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color}" ] &&
                        [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color_opponent}" ] &&
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color}" ] &&
                        [ "${_check_str63}" = "${color}" ] && [ "${_check_str64}" = "${color}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color}" ] && 
                        [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 1
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color}" ] && 
                        [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                        [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                        [ "${_check_str63}" = "${color}" ] && [ "${_check_str64}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                        [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                        [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                        [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                        [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "-" ] && 
                        [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                        [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                        [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "${color_opponent}" ] && 
                        [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && 
                        [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                        [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && 
                        [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str60}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] &&
                        [ "${_check_str62}" = "${color_opponent}" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] &&
                        [ "${_check_str62}" = "${color_opponent}" ] && 
                        [ "${_check_str63}" = "${color}" ] && [ "${_check_str64}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color}" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] &&
                        [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str60}" = "-" ] && [ "${_check_str61}" = "-" ] &&
                        [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str60}" = "${color}" ] && [ "${_check_str61}" = "${color_opponent}" ] &&
                        [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color}" ] &&
                        [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "${color_opponent}" ] &&
                        [ "${_check_str62}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] &&
                        [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] &&
                        [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str60}" = "-" ] && [ "${_check_str61}" = "${color_opponent}" ] &&
                        [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] &&
                        [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color_opponent}" ] &&
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "-" ] &&
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] &&
                        [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color}" ] &&
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "-" ] &&
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                return 1
            fi
        fi
        if [ $num -eq 62 ]; then
            _check_str57=$(cut -f 57 -d" " "${file}")
            _check_str58=$(cut -f 58 -d" " "${file}")
            _check_str59=$(cut -f 59 -d" " "${file}")
            _check_str60=$(cut -f 60 -d" " "${file}")
            _check_str61=$(cut -f 61 -d" " "${file}")
            _check_str62=$(cut -f 62 -d" " "${file}")
            _check_str63=$(cut -f 63 -d" " "${file}")
            _check_str64=$(cut -f 64 -d" " "${file}")
            _check_flippable=$(get_contents_flippables 62 | grep "55#")
            is_number_available 62
            if [ $? -eq 0 ]; then
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "${color_opponent}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "${color}" ] &&
                        [ "${_check_str62}" = "-" ] && [ "${_check_str61}" = "${color_opponent}" ] &&
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color}" ] &&
                        [ "${_check_str58}" = "${color}" ] && [ "${_check_str57}" = "${color}" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "${color}" ] && 
                        [ "${_check_str62}" = "-" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 1
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "${color}" ] && 
                        [ "${_check_str62}" = "-" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                        [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                        [ "${_check_str62}" = "-" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                        [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && 
                        [ "${_check_str58}" = "${color}" ] && [ "${_check_str57}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                        [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                        [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                        [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                        [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                        [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                        [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                        [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                        [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                        [ -z "${_check_flippable}" ]); then
                    return 0
                fi
                if [ "${_check_str61}" = "${color_opponent}" ]; then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str61}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] &&
                        [ "${_check_str59}" = "${color_opponent}" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] &&
                        [ "${_check_str59}" = "${color_opponent}" ] && 
                        [ "${_check_str58}" = "${color}" ] && [ "${_check_str57}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "${color}" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] &&
                        [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    AGGRESSIVE_SAVE=$num
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str60}" = "-" ] && [ "${_check_str61}" = "-" ] &&
                        [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str61}" = "${color}" ] && [ "${_check_str60}" = "${color_opponent}" ] &&
                        [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color}" ] &&
                        [ "${_check_str59}" = "-" ] && 
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] &&
                        [ "${_check_str59}" = "${color_opponent}" ] && 
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] &&
                        [ "${_check_str62}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] &&
                        [ "${_check_str62}" = "-" ] && [ "${_check_str61}" = "-" ] &&
                        [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "-" ] &&
                        [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] &&
                        [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color_opponent}" ] &&
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "-" ] &&
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] &&
                        [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color}" ] &&
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "-" ] &&
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                    return 0
                fi
                return 1
            fi
        fi
    fi
    ## pattern 3 ######
    if ([ $num -eq 49 ] || [ $num -eq 9 ] || [ $num -eq 16 ] || [ $num -eq 56 ] ||
            [ $num -eq 2 ] || [ $num -eq 7 ] || [ $num -eq 58 ] || [ $num -eq 63 ]); then
        if [ $REMAIN -le 4 ]; then
            return 0
        fi
        if ([ $num -eq 49 ] || [ $num -eq 9 ]); then
            _check_flippable=
            _check_str1=$(cut -f 1 -d" " "${file}")
            _check_str9=$(cut -f 9 -d" " "${file}")
            _check_str10=$(cut -f 10 -d" " "${file}")
            _check_str17=$(cut -f 17 -d" " "${file}")
            _check_str25=$(cut -f 25 -d" " "${file}")
            _check_str33=$(cut -f 33 -d" " "${file}")
            _check_str41=$(cut -f 41 -d" " "${file}")
            _check_str49=$(cut -f 49 -d" " "${file}")
            _check_str50=$(cut -f 50 -d" " "${file}")
            _check_str57=$(cut -f 57 -d" " "${file}")
            is_number_available $num
            if [ $? -eq 0 ]; then
                if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "-" ] && 
                        [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                        [ $REMAIN -le 10 ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                        [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] && 
                        [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                        [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ]); then
                    return 1
                fi
            fi
            if [ $num -eq 9 ]; then
                is_number_available 9
                if [ $? -eq 0 ]; then
                    # Check corner has priority. 
                    if ([ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str58}" = "${color_opponent}" ]); then
                        CORNER_PRIORITY=1
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "-" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 1
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "-" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 1
                    fi
                    _check_flippable=$(get_contents_flippables 9 | grep "10#")
                    if ([ $REMAIN -le 20 ] && [ "${_check_str17}" = "${color_opponent}" ] &&
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] &&
                            [ "${_check_str41}" = "-" ] && [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [  -z "${_check_flippable}" ]); then
                        PRIORITY=$num 
                        return 0
                    fi
                    ## We go aggressive in first stage.
                    if ([ $MODE = "Mode2" ] && [ $REMAIN -ge 16 ] && [ "${_check_str17}" != "${color_opponent}" ] &&
                            [  -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    # We may see this in early stage when aggressive mode.
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "${color}" ] && 
                            [ "${_check_str41}" = "-" ] && [ "${_check_str33}" = "-" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        AGGRESSIVE_SAVE=$num
                        return 0
                    fi
                    # This one is for option_reliable_than_corner in judge_position(). 
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "${color_opponent}" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "${color}" ] && 
                            [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color}" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    ## Doubtful!
                    if ([ $REMAIN -le 8 ] &&
                            [ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    ## end Doubtful!
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "-" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ $REMAIN -le 6 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color_opponent}" ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "-" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "${color}" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "${color}" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "${color}" ] && [ "${_check_str57}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "${color_opponent}" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "${color_opponent}" ]); then
                        PROBABLY_BEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "${color_opponent}" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "${color}" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "${color_opponent}" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] &&
                            [ "${_check_str49}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str9}" = "-" ] && [ "${_check_str17}" = "-" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str49}" = "${color}" ] && 
                            [ "${_check_str57}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num                    
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "${color}" ] && [ "${_check_str57}" = "${color}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "${color}" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ]); then
                        return 1
                    fi
                fi
            fi
            if [ $num -eq 49 ]; then
                is_number_available 49
                if [ $? -eq 0 ]; then
                    # Check corner has priority. 
                    if ([ "${_check_str9}" = "${color_opponent}" ] && [ "${_check_str2}" = "${color_opponent}" ]); then
                        CORNER_PRIORITY=1
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "-" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        return 1
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "-" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "-" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        return 1
                    fi
                    _check_flippable=$(get_contents_flippables 49 | grep "50#")
                    if ([ $REMAIN -le 20 ] && [ "${_check_str41}" = "${color_opponent}" ] &&
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] &&
                            [ "${_check_str17}" = "-" ] && [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                            [  -z "${_check_flippable}" ]); then
                        PRIORITY=$num 
                        return 0
                    fi
                    ## We go aggressive in first stage.
                    if ([ $MODE = "Mode2" ] && [ $REMAIN -ge 16 ] && [ "${_check_str41}" != "${color_opponent}" ] &&
                            [  -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    # We may see this in early stage when aggressive mode.
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color}" ] && 
                            [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "-" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        AGGRESSIVE_SAVE=$num
                        return 0
                    fi
                    # This one is for option_reliable_than_corner in judge_position(). 
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color}" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color}" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    ## Doubtful!
                    if ([ $REMAIN -le 8 ] &&
                            [ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    ## end Doubtful!
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "-" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                            [ $REMAIN -le 6 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color}" ] && 
                            [ "${_check_str9}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color_opponent}" ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "-" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] && 
                            [ "${_check_str9}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 5 ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color}" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color}" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str9}" = "${color}" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color_opponent}" ]); then
                        PROBABLY_BEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "${color}" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ] &&
                            [ "${_check_str9}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str9}" = "${color_opponent}" ] && 
                            [ "${_check_str17}" = "${color_opponent}" ] && [ "${_check_str25}" = "${color_opponent}" ] && 
                            [ "${_check_str33}" = "${color_opponent}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str9}" = "-" ] && [ "${_check_str17}" = "-" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str49}" = "${color_opponent}" ] && 
                            [ "${_check_str57}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color}" ] && 
                            [ "${_check_str9}" = "${color}" ] && [ "${_check_str1}" = "${color}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color}" ] && 
                            [ "${_check_str9}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str49}" = "-" ] && 
                            [ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color}" ] && 
                            [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color}" ] && 
                            [ "${_check_str9}" = "${color}" ] && [ "${_check_str1}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str9}" = "-" ] && 
                            [ "${_check_str17}" = "${color}" ] && [ "${_check_str25}" = "${color}" ] && 
                            [ "${_check_str33}" = "${color}" ] && [ "${_check_str41}" = "${color_opponent}" ] && 
                            [ "${_check_str49}" = "-" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str41}" = "${color}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                            [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ]); then
                        return 1
                    fi
                fi
            fi
            if ([ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color}" ] && 
                    [ "${_check_str25}" = "${color}" ] && [ "${_check_str17}" = "${color_opponent}" ]); then
                return 1
            fi
            if ([ "${_check_str1}" != "${color_opponent}" ] && [ "${_check_str57}" != "${color_opponent}" ]); then 
                if ([ "${_check_str41}" = "${color_opponent}" ] && [ "${_check_str33}" = "${color_opponent}" ] && 
                        [ "${_check_str25}" = "${color_opponent}" ] && [ "${_check_str17}" = "${color_opponent}" ]); then
                    if [ $num -eq 9 ]; then
                        if [ "${_check_str1}" = "${color}" ]; then
                            return 0
                        fi
                    fi
                    return 1
                fi
            fi
        fi
        if ([ $num -eq 16 ] || [ $num -eq 56 ]); then
            _check_flippable=
            _check_str8=$(cut -f 8 -d" " "${file}")
            _check_str15=$(cut -f 15 -d" " "${file}")
            _check_str16=$(cut -f 16 -d" " "${file}")
            _check_str24=$(cut -f 24 -d" " "${file}")
            _check_str32=$(cut -f 32 -d" " "${file}")
            _check_str40=$(cut -f 40 -d" " "${file}")
            _check_str48=$(cut -f 48 -d" " "${file}")
            _check_str55=$(cut -f 55 -d" " "${file}")
            _check_str56=$(cut -f 56 -d" " "${file}")
            _check_str64=$(cut -f 64 -d" " "${file}")
            is_number_available $num
            if [ $? -eq 0 ]; then
                if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str56}" = "-" ] && 
                        [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                        [ $REMAIN -le 10 ]); then
                    return 0
                fi
                if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                        [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] && 
                        [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                        [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ]); then
                    return 1
                fi
            fi
            if [ $num -eq 16 ]; then
                is_number_available 16
                if [ $? -eq 0 ]; then
                    # Check corner has priority. 
                    if ([ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str63}" = "${color_opponent}" ]); then
                        CORNER_PRIORITY=1
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "-" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 1
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "-" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 1
                    fi
                    _check_flippable=$(get_contents_flippables 16 | grep "15#")
                    if ([ $REMAIN -le 20 ] && [ "${_check_str24}" = "${color_opponent}" ] &&
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] &&
                            [ "${_check_str48}" = "-" ] && [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [  -z "${_check_flippable}" ]); then
                        PRIORITY=$num 
                        return 0
                    fi
                    ## We go aggressive in first stage.
                    if ([ $MODE = "Mode2" ] && [ $REMAIN -ge 16 ] && [ "${_check_str24}" != "${color_opponent}" ] &&
                            [  -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    # We may see this in early stage when aggressive mode.
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "${color}" ] && 
                            [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "-" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        AGGRESSIVE_SAVE=$num
                        return 0
                    fi
                    # This one is for option_reliable_than_corner in judge_position(). 
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "${color_opponent}" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "${color}" ] && 
                            [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color}" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    ## Doubtful!
                    if ([ $REMAIN -le 8 ] &&
                            [ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    ## end Doubtful!
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "-" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ $REMAIN -le 6 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "${color}" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "${color}" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "${color}" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "-" ]); then
                        PROBABLY_BEST=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "${color_opponent}" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "${color}" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "${color_opponent}" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] &&
                            [ "${_check_str56}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "${color}" ] && [ "${_check_str64}" = "${color}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "${color}" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ]); then
                        return 1
                    fi
                fi
            fi
            if [ $num -eq 56 ]; then
                is_number_available 56
                if [ $? -eq 0 ]; then
                    # Check corner has priority. 
                    if ([ "${_check_str16}" = "${color_opponent}" ] && [ "${_check_str7}" = "${color_opponent}" ]); then
                        CORNER_PRIORITY=1
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "-" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 1
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "-" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 1
                    fi
                    _check_flippable=$(get_contents_flippables 56 | grep "55#")
                    if ([ $REMAIN -le 20 ] && [ "${_check_str48}" = "${color_opponent}" ] &&
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] &&
                            [ "${_check_str24}" = "-" ] && [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [  -z "${_check_flippable}" ]); then
                        PRIORITY=$num 
                        return 0
                    fi
                    ## We go aggressive in first stage.
                    if ([ $MODE = "Mode2" ] && [ $REMAIN -ge 16 ] && [ "${_check_str48}" != "${color_opponent}" ] &&
                            [  -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    # We may see this in early stage when aggressive mode.
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color}" ] && 
                            [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "-" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        AGGRESSIVE_SAVE=$num
                        return 0
                    fi
                    # This one is for option_reliable_than_corner in judge_position(). 
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color}" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    ## Doubtful!
                    if ([ $REMAIN -le 8 ] &&
                            [ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    ## Doubtful!
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "-" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ $REMAIN -le 6 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color}" ] && 
                            [ "${_check_str16}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "-" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ] && 
                            [ "${_check_str16}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 5 ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color}" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color}" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str16}" = "${color}" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        PROBABLY_BEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "${color}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ] &&
                            [ "${_check_str16}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str16}" = "${color_opponent}" ] && 
                            [ "${_check_str24}" = "${color_opponent}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color_opponent}" ] && 
                            [ "${_check_str40}" = "${color_opponent}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color}" ] && 
                            [ "${_check_str16}" = "${color}" ] && [ "${_check_str8}" = "${color}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color}" ] && 
                            [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str56}" = "-" ] && 
                            [ "${_check_str48}" = "${color_opponent}" ] && [ "${_check_str40}" = "${color}" ] && 
                            [ "${_check_str32}" = "${color}" ] && [ "${_check_str24}" = "${color}" ] && 
                            [ "${_check_str16}" = "${color}" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str16}" = "-" ] && 
                            [ "${_check_str24}" = "${color}" ] && [ "${_check_str32}" = "${color}" ] && 
                            [ "${_check_str40}" = "${color}" ] && [ "${_check_str48}" = "${color_opponent}" ] && 
                            [ "${_check_str56}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str48}" = "${color}" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                            [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "${color_opponent}" ]); then
                        return 1
                    fi
                fi
            fi
        fi
        if ([ $num -eq 2 ] || [ $num -eq 7 ]); then
            _check_flippable=
            _check_str1=$(cut -f 1 -d" " "${file}")
            _check_str2=$(cut -f 2 -d" " "${file}")
            _check_str3=$(cut -f 3 -d" " "${file}")
            _check_str4=$(cut -f 4 -d" " "${file}")
            _check_str5=$(cut -f 5 -d" " "${file}")
            _check_str6=$(cut -f 6 -d" " "${file}")
            _check_str7=$(cut -f 7 -d" " "${file}")
            _check_str8=$(cut -f 8 -d" " "${file}")
            _check_str9=$(cut -f 9 -d" " "${file}")
            _check_str10=$(cut -f 10 -d" " "${file}")
            _check_str15=$(cut -f 15 -d" " "${file}")
            _check_str16=$(cut -f 16 -d" " "${file}")
            is_number_available $num
            if [ $? -eq 0 ]; then
                if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "-" ] && 
                        [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                        [ $REMAIN -le 10 ]); then
                    return 0
                fi
                if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                        [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] && 
                        [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ]); then
                    return 1
                fi
            fi
            if [ $num -eq 2 ]; then
                is_number_available 2
                if [ $? -eq 0 ]; then
                    # Check corner has priority. 
                    if ([ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str16}" = "${color_opponent}" ]); then
                        CORNER_PRIORITY=1
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "-" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        return 1
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "-" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 1
                    fi
                    _check_flippable=$(get_contents_flippables 2 | grep "10#")
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && [ "${_check_str3}" = "${color_opponent}" ] &&
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] &&
                            [ "${_check_str6}" = "${color}" ] && [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [  -z "${_check_flippable}" ]); then
                        PROBABLY_BEST=$num 
                        return 0
                    fi
                    if ([ $REMAIN -le 20 ] && [ "${_check_str3}" = "${color_opponent}" ] &&
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] &&
                            [ "${_check_str6}" = "-" ] && [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [  -z "${_check_flippable}" ]); then
                        PRIORITY=$num 
                        return 0
                    fi
                    ## We go aggressive in first stage.
                    if ([ $MODE = "Mode2" ] && [ $REMAIN -ge 16 ] && [ "${_check_str3}" != "${color_opponent}" ] &&
                            [  -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    # We may see this in early stage when aggressive mode.
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "${color}" ] && 
                            [ "${_check_str6}" = "-" ] && [ "${_check_str5}" = "-" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        AGGRESSIVE_SAVE=$num
                        return 0
                    fi
                    # This one is for option_reliable_than_corner in judge_position(). 
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "${color_opponent}" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "${color}" ] && 
                            [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color}" ] && [ "${_check_str8}" = "${color}" ]); then
                        return 0
                    fi
                    ## Doubtful!
                    if ([ $REMAIN -le 8 ] &&
                            [ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    ## end Doubtful!
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "-" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ $REMAIN -le 6 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "-" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "${color}" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "${color}" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "${color}" ] && [ "${_check_str8}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "-" ]); then
                        PROBABLY_BEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "${color_opponent}" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str7}" = "${color}" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "${color_opponent}" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] &&
                            [ "${_check_str7}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "${color_opponent}" ] && [ "${_check_str8}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "${color}" ] && [ "${_check_str8}" = "${color}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "${color}" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ]); then
                        return 1
                    fi
                fi
            fi
            if [ $num -eq 7 ]; then
                is_number_available 7
                if [ $? -eq 0 ]; then
                    # Check corner has priority. 
                    if ([ "${_check_str2}" = "${color_opponent}" ] && [ "${_check_str9}" = "${color_opponent}" ]); then
                        CORNER_PRIORITY=1
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "-" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 1
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "-" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "-" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        return 1
                    fi
                    _check_flippable=$(get_contents_flippables 7 | grep "15#")
                    if ([ $REMAIN -le 20 ] && [ "${_check_str6}" = "${color_opponent}" ] &&
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] &&
                            [ "${_check_str3}" = "-" ] && [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                            [  -z "${_check_flippable}" ]); then
                        PRIORITY=$num 
                        return 0
                    fi
                    ## We go aggressive in first stage.
                    if ([ $MODE = "Mode2" ] && [ $REMAIN -ge 16 ] && [ "${_check_str6}" != "${color_opponent}" ] &&
                            [  -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    # We may see this in early stage when aggressive mode.
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color}" ] && 
                            [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "-" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        AGGRESSIVE_SAVE=$num
                        return 0
                    fi
                    # This one is for option_reliable_than_corner in judge_position(). 
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color}" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    ## Doubtful!
                    if ([ $REMAIN -le 8 ] &&
                            [ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    ## end Doubtful!
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "-" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                            [ $REMAIN -le 6 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color_opponent}" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && 
                            [ "${_check_str2}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color_opponent}" ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "-" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ] && 
                            [ "${_check_str2}" = "${color_opponent}" ] && [ "${_check_str1}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 5 ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color}" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color}" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color_opponent}" ] && [ "${_check_str2}" = "${color}" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ]); then
                        PROBABLY_BEST=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "${color}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ] &&
                            [ "${_check_str2}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "${color}" ] && [ "${_check_str2}" = "${color_opponent}" ] && 
                            [ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                            [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "${color}" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && 
                            [ "${_check_str2}" = "${color}" ] && [ "${_check_str1}" = "${color}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && 
                            [ "${_check_str2}" = "-" ] && [ "${_check_str1}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str8}" = "-" ] && [ "${_check_str7}" = "-" ] && 
                            [ "${_check_str6}" = "${color_opponent}" ] && [ "${_check_str5}" = "${color}" ] && 
                            [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color}" ] && 
                            [ "${_check_str2}" = "${color}" ] && [ "${_check_str1}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str1}" = "-" ] && [ "${_check_str2}" = "-" ] && 
                            [ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] && 
                            [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ] && 
                            [ "${_check_str7}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color_opponent}" ] && 
                            [ "${_check_str4}" = "${color_opponent}" ] && [ "${_check_str3}" = "${color_opponent}" ]); then
                        return 1
                    fi
                fi
            fi
            if ([ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color}" ] && 
                    [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ]); then
                return 1
            fi
            if ([ "${_check_str1}" != "${color_opponent}" ] && [ "${_check_str8}" = "${color_opponent}" ]); then 
                if ([ "${_check_str3}" = "${color_opponent}" ] && [ "${_check_str4}" = "${color_opponent}" ] && 
                        [ "${_check_str5}" = "${color_opponent}" ] && [ "${_check_str6}" = "${color_opponent}" ]); then
                    if [ $num -eq 2 ]; then
                        if ([ "${_check_str3}" = "${color}" ] && [ "${_check_str4}" = "${color}" ] &&
                                [ "${_check_str5}" = "${color}" ] && [ "${_check_str6}" = "${color_opponent}" ]); then 
                            return 1
                        fi
                        if [ "${_check_str7}" = "${color_opponent}" ]; then
                            return 0
                        fi
                    fi
                    if [ $num -eq 7 ]; then
                        if ([ "${_check_str6}" = "${color}" ] && [ "${_check_str5}" = "${color}" ] &&
                                 [ "${_check_str4}" = "${color}" ] && [ "${_check_str3}" = "${color_opponent}" ]); then 
                            return 1
                        fi
                        if [ "${_check_str2}" = "${color_opponent}" ]; then
                            return 0
                        fi
                    fi
                    return 1
                fi
            fi
        fi
        if ([ $num -eq 58 ] || [ $num -eq 63 ]); then
            _check_flippable=
            _check_str50=$(cut -f 50 -d" " "${file}")
            _check_str55=$(cut -f 55 -d" " "${file}")
            _check_str57=$(cut -f 57 -d" " "${file}")
            _check_str58=$(cut -f 58 -d" " "${file}")
            _check_str59=$(cut -f 59 -d" " "${file}")
            _check_str60=$(cut -f 60 -d" " "${file}")
            _check_str61=$(cut -f 61 -d" " "${file}")
            _check_str62=$(cut -f 62 -d" " "${file}")
            _check_str63=$(cut -f 63 -d" " "${file}")
            _check_str64=$(cut -f 64 -d" " "${file}")
            is_number_available $num
            if [ $? -eq 0 ]; then
                if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str56}" = "-" ] && 
                        [ "${_check_str48}" = "-" ] && [ "${_check_str40}" = "${color_opponent}" ] && 
                        [ "${_check_str32}" = "${color_opponent}" ] && [ "${_check_str24}" = "-" ] && 
                        [ "${_check_str16}" = "-" ] && [ "${_check_str8}" = "${color_opponent}" ] &&
                        [ $REMAIN -le 10 ]); then
                    return 0
                fi
                if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                        [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] && 
                        [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ]); then
                    return 1
                fi
            fi
            if [ $num -eq 58 ]; then
                is_number_available 58
                if [ $? -eq 0 ]; then
                    # Check corner has priority. 
                    if ([ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str56}" = "${color_opponent}" ]); then
                        CORNER_PRIORITY=1
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "-" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 1
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "-" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 1
                    fi
                    _check_flippable=$(get_contents_flippables 58 | grep "50#")
                    ## We go aggressive in first stage.
                    if ([ $MODE = "Mode2" ] && [ $REMAIN -ge 16 ] && [ "${_check_str59}" != "${color_opponent}" ] &&
                            [  -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    # We may see this in early stage when aggressive mode.
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "${color}" ] && 
                            [ "${_check_str62}" = "-" ] && [ "${_check_str61}" = "-" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        AGGRESSIVE_SAVE=$num
                        return 0
                    fi
                    # This one is for option_reliable_than_corner in judge_position(). 
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "${color_opponent}" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "${color}" ] && 
                            [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "${color}" ] && [ "${_check_str57}" = "${color}" ]); then
                        return 0
                    fi
                    ## Doubtful!
                    if ([ $REMAIN -le 8 ] &&
                            [ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    ## end Doubtful!
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "-" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ $REMAIN -le 6 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "${color}" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "-" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "${color}" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "${color}" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "${color}" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "-" ]); then
                        PROBABLY_BEST=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "${color_opponent}" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str63}" = "${color}" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "${color_opponent}" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] &&
                            [ "${_check_str63}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "${color_opponent}" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "${color}" ] && [ "${_check_str64}" = "${color}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "${color}" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ]); then
                        return 1
                    fi
                fi
            fi
            if [ $num -eq 63 ]; then
                is_number_available 63
                if [ $? -eq 0 ]; then
                    # Check corner has priority. 
                    if ([ "${_check_str58}" = "${color_opponent}" ] && [ "${_check_str49}" = "${color_opponent}" ]); then
                        CORNER_PRIORITY=1
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "-" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 1
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "-" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "-" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 1
                    fi
                    _check_flippable=$(get_contents_flippables 63 | grep "55#")
                    ## We go aggressive in first stage.
                    if ([ $MODE = "Mode2" ] && [ $REMAIN -ge 16 ] && [ "${_check_str62}" != "${color_opponent}" ] &&
                            [  -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    # We may see this in early stage when aggressive mode.
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color}" ] && 
                            [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "-" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        AGGRESSIVE_SAVE=$num
                        return 0
                    fi
                    # This one is for option_reliable_than_corner in judge_position(). 
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color}" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    ## Doubtful!
                    if ([ $REMAIN -le 8 ] &&
                            [ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        LAST_RESORT=$num
                        return 0
                    fi
                    ## end Doubtful!
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color}" ] &&
                            [ $REMAIN -le 5 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "-" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ $REMAIN -le 6 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color_opponent}" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && 
                            [ "${_check_str58}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color_opponent}" ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "-" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ $REMAIN -le 5 ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color}" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] && 
                            [ "${_check_str58}" = "${color_opponent}" ] && [ "${_check_str57}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        SAFEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color}" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color_opponent}" ] && [ "${_check_str58}" = "${color}" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ]); then
                        PROBABLY_BEST=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "${color}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        EMERGENCY=0
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ]); then
                        return 0
                    fi
                    if ([ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ] &&
                            [ "${_check_str58}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "${color}" ] && [ "${_check_str58}" = "${color_opponent}" ] && 
                            [ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                            [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "${color}" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && 
                            [ "${_check_str58}" = "${color}" ] && [ "${_check_str57}" = "${color}" ] &&
                            [ $REMAIN -le 2 ]); then
                        EMERGENCY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && 
                            [ "${_check_str58}" = "-" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str64}" = "-" ] && [ "${_check_str63}" = "-" ] && 
                            [ "${_check_str62}" = "${color_opponent}" ] && [ "${_check_str61}" = "${color}" ] && 
                            [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color}" ] && 
                            [ "${_check_str58}" = "${color}" ] && [ "${_check_str57}" = "-" ] &&
                            [ -z "${_check_flippable}" ]); then
                        PRIORITY=$num
                        return 0
                    fi
                    if ([ "${_check_str57}" = "-" ] && [ "${_check_str58}" = "-" ] && 
                            [ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] && 
                            [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ] && 
                            [ "${_check_str63}" = "-" ] && [ "${_check_str64}" = "${color_opponent}" ] &&
                            [ -z "${_check_flippable}" ]); then
                        return 0
                    fi
                    if ([ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color_opponent}" ] && 
                            [ "${_check_str60}" = "${color_opponent}" ] && [ "${_check_str59}" = "${color_opponent}" ]); then
                        return 1
                    fi
                fi
            fi
            if ([ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color}" ] && 
                    [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ]); then
                return 1
            fi
            if ([ "${_check_str57}" != "${color_opponent}" ] && [ "${_check_str64}" != "${color_opponent}" ]); then 
                if ([ "${_check_str59}" = "${color_opponent}" ] && [ "${_check_str60}" = "${color_opponent}" ] && 
                        [ "${_check_str61}" = "${color_opponent}" ] && [ "${_check_str62}" = "${color_opponent}" ]); then
                    return 1
                fi
            fi
            if [ $num -eq 58 ]; then
                if ([ "${_check_str59}" = "${color}" ] && [ "${_check_str60}" = "${color}" ] &&
                        [ "${_check_str61}" = "${color}" ] && [ "${_check_str62}" = "${color_opponent}" ]); then 
                    return 1
                fi
            fi
            if [ $num -eq 63 ]; then
                if ([ "${_check_str62}" = "${color}" ] && [ "${_check_str61}" = "${color}" ] &&
                        [ "${_check_str60}" = "${color}" ] && [ "${_check_str59}" = "${color_opponent}" ]); then 
                    return 1
                fi
            fi
        fi

    fi
    ## pattern 4 ######
    if ([ $num -eq 10 ] || [ $num -eq 15 ] || [ $num -eq 50 ] || [ $num -eq 55 ]); then
        if [ $REMAIN -le 8 ]; then
            return 0
        fi
        _check_str10=$(cut -f 10 -d" " "${file}")
        _check_str19=$(cut -f 19 -d" " "${file}")
        _check_str22=$(cut -f 22 -d" " "${file}")
        _check_str28=$(cut -f 28 -d" " "${file}")
        _check_str29=$(cut -f 29 -d" " "${file}")
        _check_str36=$(cut -f 36 -d" " "${file}")
        _check_str37=$(cut -f 37 -d" " "${file}")
        _check_str43=$(cut -f 43 -d" " "${file}")
        _check_str46=$(cut -f 46 -d" " "${file}")
        _check_str55=$(cut -f 55 -d" " "${file}")
        if ([ $num -eq 10 ]); then
            is_number_available 10 
            if [ $? -eq 0 ]; then
                if ([ "${_check_str19}" = "${color_opponent}" ] && [ "${_check_str28}" = "${color_opponent}" ] && 
                        [ "${_check_str37}" = "${color_opponent}" ] && [ "${_check_str46}" = "${color}" ]); then
                    return 0
                fi
            fi
        fi
        if ([ $num -eq 15 ]); then
            is_number_available 15 
            if [ $? -eq 0 ]; then
                if ([ "${_check_str22}" = "${color_opponent}" ] && [ "${_check_str29}" = "${color_opponent}" ] && 
                        [ "${_check_str36}" = "${color_opponent}" ] && [ "${_check_str43}" = "${color}" ]); then
                    return 0
                fi
            fi
        fi
        if ([ $num -eq 50 ]); then
            is_number_available 50 
            if [ $? -eq 0 ]; then
                if ([ "${_check_str43}" = "${color_opponent}" ] && [ "${_check_str36}" = "${color_opponent}" ] && 
                        [ "${_check_str29}" = "${color_opponent}" ] && [ "${_check_str22}" = "${color}" ]); then
                    return 0
                fi
            fi
        fi
        if ([ $num -eq 55 ]); then
            is_number_available 55 
            if [ $? -eq 0 ]; then
                if ([ "${_check_str46}" = "${color_opponent}" ] && [ "${_check_str37}" = "${color_opponent}" ] && 
                        [ "${_check_str28}" = "${color_opponent}" ] && [ "${_check_str19}" = "${color}" ]); then
                    return 0
                fi
            fi
        fi
    fi
    return 1
}

## This function counts flippables for a certain number.
## var1: number
##

function count_flippables()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    local num="${1}" 
    local str_c=0
    number="#${num}:" 
    str_c=$(echo "${FLIPPABLE_ALL[*]}" | awk -F" " -v pat="$number" '{for(i=1;i<=NF;i++) if($i ~ pat) c++} END {print c}' | sed -e 's/ //g') 
    if [ -z $str_c ]; then
        str_c=0
    fi
    echo $str_c
}

## This function gets flippables for a certain number.
## var1: number
##

function get_contents_flippables()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as the number." >&2
        exit 1
    fi
    local num="${1}" 
    local str_c=0
    number="#${num}:" 
    number_v="#${num}:" 
    str=$(echo "${FLIPPABLE_ALL[*]}" | awk -F" " -v pat="$number" '{for(i=1;i<=NF;i++) if($i ~ pat){printf("%s ",$i)}}' | sed -e "s/${number_v}//g") 
    echo $str
}

## This function places and flips.
## var1: position
## var2: color
##

function place_and_flip()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as the position." >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as the color." >&2
        echo "Ex. Black, White" >&2
        exit 1
    fi
    local position=0
    local flippables=0
    local flippable=0
    local flippable_cnt=0
    local color=0
    position="${1}"
    color="${2}"
    #echo "Place $position."
    if [ "${color}" = "Black" ]; then
        color="B"
    elif [ "${color}" = "White" ]; then
        color="W"
    else
        echo "Oops, color is wrong." >&2
        exit 1
    fi
    awk -F" " -v pos=$position -v col=$color '{$pos=col}1' "${FILE_KIFU_PRESENT}"  > "${FILE_KIFU_PRESENT}_tmp"
    mv "${FILE_KIFU_PRESENT}_tmp" "${FILE_KIFU_PRESENT}"
    flippables=$(get_contents_flippables $position)
    #echo "Flippables: $flippables."
    flippable_cnt=$(echo $flippables | awk -F" " '{print NF}')
    while [ $flippable_cnt -gt 0 ]
    do
        flippable=$(echo $flippables | awk -F" " -v pos=$flippable_cnt '{print $pos}')
        awk -F" " -v pos=$flippable -v col=$color '{$pos=col}1' "${FILE_KIFU_PRESENT}"  > "${FILE_KIFU_PRESENT}_tmp"
        mv "${FILE_KIFU_PRESENT}_tmp" "${FILE_KIFU_PRESENT}"
        flippable_cnt=$((flippable_cnt - 1))
    done
    EMERGENCY=1
}

## This function check every flippables and finalize the position.
## var1: color 
## var2: identifier 
##

function judge_position()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as the color." >&2
        echo "Ex. Black, White" >&2
        exit 1
    fi
    if [ -z "${2}" ]; then
        echo "Please give a variable as human identifier." >&2
        echo "Ex. 1 which is Human, 0 which is Computer." >&2
        exit 1
    fi
    local color=0
    local human=0
    color="${1}"
    human="${2}"

    # This is the variable we want for the computer.
    local position=0
    #local position_rim=0
    local position_reliable_than_corner=0
    local position_including_others=0
    local position_aggressive=0

    local position_upper_rim_sub_corner=0
    local position_right_rim_sub_corner=0
    local position_down_rim_sub_corner=0
    local position_left_rim_sub_corner=0
    local position_upper_rim=0
    local position_right_rim=0
    local position_down_rim=0
    local position_left_rim=0
    local position_sub_upper_rim=0
    local position_sub_right_rim=0
    local position_sub_down_rim=0
    local position_sub_left_rim=0
    local position_upper_rim_above=0
    local position_right_rim_above=0
    local position_down_rim_above=0
    local position_left_rim_above=0
    local flippables_1=0
    local flippables_2=0
    local flippables_3=0
    local flippables_4=0
    local flippables_5=0
    local flippables_6=0
    local flippables_7=0
    local flippables_8=0
    local flippables_9=0
    local flippables_10=0
    local flippables_11=0
    local flippables_12=0
    local flippables_13=0
    local flippables_14=0
    local flippables_15=0
    local flippables_16=0
    local flippables_17=0
    local flippables_18=0
    local flippables_19=0
    local flippables_20=0
    local flippables_21=0
    local flippables_22=0
    local flippables_23=0
    local flippables_24=0
    local flippables_25=0
    local flippables_26=0
    local flippables_27=0
    local flippables_28=0
    local flippables_29=0
    local flippables_30=0
    local flippables_31=0
    local flippables_32=0
    local flippables_33=0
    local flippables_34=0
    local flippables_35=0
    local flippables_36=0
    local flippables_37=0
    local flippables_38=0
    local flippables_39=0
    local flippables_40=0
    local flippables_41=0
    local flippables_42=0
    local flippables_43=0
    local flippables_44=0
    local flippables_45=0
    local flippables_46=0
    local flippables_47=0
    local flippables_48=0
    local flippables_49=0
    local flippables_50=0
    local flippables_51=0
    local flippables_52=0
    local flippables_53=0
    local flippables_54=0
    local flippables_55=0
    local flippables_56=0
    local flippables_57=0
    local flippables_58=0
    local flippables_59=0
    local flippables_60=0
    local flippables_61=0
    local flippables_62=0
    local flippables_63=0
    local flippables_64=0
    local flippables_aggressive=0
    local array=()
    local i_pre
    local i 
    local n_is_corner_available=1 
    local n_is_sub_corner_available=1 
    local n_is_upper_rim_sub_corner_available=1
    local n_is_right_rim_sub_corner_available=1
    local n_is_down_rim_sub_corner_available=1
    local n_is_left_rim_sub_corner_available=1
    local n_is_upper_rim_available=1
    local n_is_right_rim_available=1
    local n_is_down_rim_available=1
    local n_is_left_rim_available=1
    local n_is_sub_upper_rim_available=1
    local n_is_sub_right_rim_available=1
    local n_is_sub_down_rim_available=1
    local n_is_sub_left_rim_available=1
    local n_is_upper_rim_above_available=1
    local n_is_right_rim_above_available=1
    local n_is_down_rim_above_available=1
    local n_is_left_rim_above_available=1
    local rtn=1
    is_corner_available
    n_is_corner_available=$?
    is_sub_corner_available
    n_is_sub_corner_available=$?
    is_upper_rim_sub_corner_available
    n_is_upper_rim_sub_corner_available=$?
    is_right_rim_sub_corner_available
    n_is_right_rim_sub_corner_available=$?
    is_down_rim_sub_corner_available
    n_is_down_rim_sub_corner_available=$?
    is_left_rim_sub_corner_available
    n_is_left_rim_sub_corner_available=$?
    is_upper_rim_available
    n_is_upper_rim_available=$?
    is_right_rim_available
    n_is_right_rim_available=$?
    is_down_rim_available
    n_is_down_rim_available=$?
    is_left_rim_available
    n_is_left_rim_available=$?
    is_sub_upper_rim_available
    n_is_sub_upper_rim_available=$?
    is_sub_right_rim_available
    n_is_sub_right_rim_available=$?
    is_sub_down_rim_available
    n_is_sub_down_rim_available=$?
    is_sub_left_rim_available
    n_is_sub_left_rim_available=$?
    is_upper_rim_above_available
    n_is_upper_rim_above_available=$?
    is_right_rim_above_available
    n_is_right_rim_above_available=$?
    is_down_rim_above_available
    n_is_down_rim_above_available=$?
    is_left_rim_above_available
    n_is_left_rim_above_available=$?

    if [ $n_is_corner_available -eq 0 ]; then
        #echo "corner avaiable"
        array=()
        array2=()
        is_number_available 1
        if [ $? -eq 0 ]; then
            is_number_available 7
            if [ $? -eq 0 ]; then
                is_number_safe 7 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    position_reliable_than_corner=7

                fi
            fi
            flippables_1=$(count_flippables 1)
        fi
        is_number_available 8
        if [ $? -eq 0 ]; then
            is_number_available 2
            if [ $? -eq 0 ]; then
                is_number_safe 2 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    position_reliable_than_corner=2
                fi
            fi
            flippables_8=$(count_flippables 8)
        fi
        is_number_available 57
        if [ $? -eq 0 ]; then
            is_number_available 63 
            if [ $? -eq 0 ]; then
                is_number_safe 63 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    position_reliable_than_corner=63
                fi
            fi
            flippables_57=$(count_flippables 57)
        fi
        is_number_available 64
        if [ $? -eq 0 ]; then
            is_number_available 58 
            if [ $? -eq 0 ]; then
                is_number_safe 58 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    position_reliable_than_corner=58
                fi
            fi
            flippables_64=$(count_flippables 64)
        fi
        array=($flippables_1 $flippables_8 $flippables_57 $flippables_64)    
        array2=(1 8 57 64)
        i=0
        i_pre=0
        # multiple array loop
        position=0
        for i in ${!array[@]};
        do
            if [ ${array[i]} -gt $i_pre ]; then
                position=${array2[i]}
                i_pre=${array[i]}
            fi
        done
    elif ([ $n_is_upper_rim_available -eq 0 ] || [ $n_is_right_rim_available -eq 0 ] || [ $n_is_down_rim_available -eq 0 ] || [ $n_is_left_rim_available -eq 0 ]); then
        if [ $n_is_upper_rim_available -eq 0 ]; then
            #echo "upper rim available"
            array=()
            array2=()
            is_number_available 4
            if [ $? -eq 0 ]; then
                is_number_safe 4 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    is_number_safe 4 "${COMPUTER}"
                    if [ $? -ne 1 ]; then
                        flippables_4=$(count_flippables 4)
                    fi
                fi
            fi
            is_number_available 5
            if [ $? -eq 0 ]; then
                is_number_safe 5 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    is_number_safe 5 "${COMPUTER}"
                    if [ $? -ne 1 ]; then
                        flippables_5=$(count_flippables 5)
                    fi
                fi
            fi
            array=($flippables_4 $flippables_5)    
            array2=(4 5)
            i=0
            i_pre=0
            # multiple array loop
            position_upper_rim=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_upper_rim=${array2[i]}
                fi
            done
        fi
        # Here, not elif but if. Same below.
        if [ $n_is_right_rim_available -eq 0 ]; then
            #echo "right rim avaiable"
            array=()
            array2=()
            is_number_available 32
            if [ $? -eq 0 ]; then
                is_number_safe 32 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_32=$(count_flippables 32)
                fi
            fi
            is_number_available 40
            if [ $? -eq 0 ]; then
                is_number_safe 40 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_40=$(count_flippables 40)
                fi
            fi
            array=($flippables_32 $flippables_40)    
            array2=(32 40)
            i=0
            i_pre=0
            # multiple array loop
            position_right_rim=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_right_rim=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
        if [ $n_is_down_rim_available -eq 0 ]; then
            #echo "down rim avaiable"
            array=()
            array2=()
            is_number_available 60
            if [ $? -eq 0 ]; then
                is_number_safe 60 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_60=$(count_flippables 60)
                fi
            fi
            is_number_available 61
            if [ $? -eq 0 ]; then
                is_number_safe 61 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_61=$(count_flippables 61)
                fi
            fi
            array=($flippables_60 $flippables_61)    
            array2=(60 61)
            i=0
            i_pre=0
            # multiple array loop
            position_down_rim=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_down_rim=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
        if [ $n_is_left_rim_available -eq 0 ]; then
            #echo "left rim avaiable"
            array=()
            array2=()
            is_number_available 25
            if [ $? -eq 0 ]; then
                is_number_safe 25 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_25=$(count_flippables 25)
                fi
            fi
            is_number_available 33
            if [ $? -eq 0 ]; then
                is_number_safe 33 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_33=$(count_flippables 33)
                fi
            fi
            array=($flippables_25 $flippables_33)    
            array2=(25 33)
            i=0
            i_pre=0
            # multiple array loop
            position_left_rim=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_left_rim=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
        ### Compare positions and set the position which has largest flippable number.
        if ([ $flippables_4 -ne 0 ] || [ $flippables_5 -ne 0 ] || [ $flippables_32 -ne 0 ] || [ $flippables_40 -ne 0 ] ||   
                [ $flippables_60 -ne 0 ] || [ $flippables_61 -ne 0 ] || [ $flippables_25 -ne 0 ] || [ $flippables_33 -ne 0 ]); then    
            array=()
            array2=()
            array=($flippables_4 $flippables_5 $flippables_32 $flippables_40 $flippables_60 $flippables_61 $flippables_25 $flippables_33)    
            array2=(4 5 32 40 60 61 25 33)
            i=0
            i_pre=0
            # multiple array loop
            #position=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi

    elif [ $n_is_sub_corner_available -eq 0 ]; then
        #echo "sub-corner avaiable"
        array=()
        array2=()
        is_number_available 19
        if [ $? -eq 0 ]; then
            flippables_19=$(count_flippables 19)
        fi
        is_number_available 22
        if [ $? -eq 0 ]; then
            flippables_22=$(count_flippables 22)
        fi
        is_number_available 43
        if [ $? -eq 0 ]; then
            flippables_43=$(count_flippables 43)
        fi
        is_number_available 46
        if [ $? -eq 0 ]; then
            flippables_46=$(count_flippables 46)
        fi
        if ([ $flippables_19 -ne 0 ] || [ $flippables_22 -ne 0 ] || [ $flippables_43 -ne 0 ] || [ $flippables_46 -ne 0 ]); then    
            array=()
            array2=()
            array=($flippables_19 $flippables_22 $flippables_43 $flippables_46)    
            array2=(19 22 43 46)
            i=0
            i_pre=0
            # multiple array loop
            #position=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
    elif ([ $n_is_upper_rim_sub_corner_available -eq 0 ] || [ $n_is_right_rim_sub_corner_available -eq 0 ] || [ $n_is_down_rim_sub_corner_available -eq 0 ] || [ $n_is_left_rim_sub_corner_available -eq 0 ]); then
        if [ $n_is_upper_rim_sub_corner_available -eq 0 ]; then
            #echo "upper rim sub-corner avaiable"
            array=()
            array2=()
            is_number_available 3
            if [ $? -eq 0 ]; then
                is_number_safe 3 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_3=$(count_flippables 3)
                fi
            fi
            is_number_available 6
            if [ $? -eq 0 ]; then
                is_number_safe 6 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_6=$(count_flippables 6)
                fi
            fi
            array=($flippables_3 $flippables_6)    
            array2=(3 6)
            i=0
            i_pre=0
            # multiple array loop
            position_upper_rim_sub_corner=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_upper_rim_sub_corner=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
        # Here, not elif but if. Same below.
        if [ $n_is_right_rim_sub_corner_available -eq 0 ]; then
            #echo "right rim sub-corner avaiable"
            array=()
            array2=()
            is_number_available 24
            if [ $? -eq 0 ]; then
                is_number_safe 24 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_24=$(count_flippables 24)
                fi
            fi
            is_number_available 48
            if [ $? -eq 0 ]; then
                is_number_safe 48 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_48=$(count_flippables 48)
                fi
            fi
            array=($flippables_24 $flippables_48)    
            array2=(24 48)
            i=0
            i_pre=0
            # multiple array loop
            position_right_rim_sub_corner=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_right_rim_sub_corner=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
        if [ $n_is_down_rim_sub_corner_available -eq 0 ]; then
            #echo "down rim sub-corner vaiable"
            array=()
            array2=()
            is_number_available 59
            if [ $? -eq 0 ]; then
                is_number_safe 59 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_59=$(count_flippables 59)
                fi
            fi
            is_number_available 62
            if [ $? -eq 0 ]; then
                is_number_safe 62 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_62=$(count_flippables 62)
                fi
            fi
            array=($flippables_59 $flippables_62)    
            array2=(59 62)
            i=0
            i_pre=0
            # multiple array loop
            position_down_rim_sub_corner=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_down_rim_sub_corner=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
        if [ $n_is_left_rim_sub_corner_available -eq 0 ]; then
            #echo "left rim sub-corner avaiable"
            array=()
            array2=()
            is_number_available 17
            if [ $? -eq 0 ]; then
                is_number_safe 17 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_17=$(count_flippables 17)
                fi
            fi
            is_number_available 41
            if [ $? -eq 0 ]; then
                is_number_safe 41 "${COMPUTER}"
                if [ $? -ne 1 ]; then
                    flippables_41=$(count_flippables 41)
                fi
            fi
            array=($flippables_17 $flippables_41)    
            array2=(17 41)
            i=0
            i_pre=0
            # multiple array loop
            position_left_rim_sub_corner=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_left_rim_sub_corner=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
        ### Compare positions and set the position which has largest flippable number.
        if ([ $flippables_3 -ne 0 ] || [ $flippables_6 -ne 0 ] || [ $flippables_24 -ne 0 ] || [ $flippables_48 -ne 0 ] ||   
                [ $flippables_59 -ne 0 ] || [ $flippables_62 -ne 0 ] || [ $flippables_17 -ne 0 ] || [ $flippables_41 -ne 0 ]); then    
            array=()
            array2=()
            array=($flippables_3 $flippables_6 $flippables_24 $flippables_48 $flippables_59 $flippables_62 $flippables_17 $flippables_41)    
            array2=(3 6 24 48 59 62 17 41)
            i=0
            i_pre=0
            # multiple array loop
            #position=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
    fi
    #echo "position_first_check:$position"

    # Here we start anew.
    if [ $position -eq 0 ]; then
        if ([ $n_is_sub_upper_rim_available -eq 0 ] || [ $n_is_sub_right_rim_available -eq 0 ] || [ $n_is_sub_down_rim_available -eq 0 ] || [ $n_is_sub_left_rim_available -eq 0 ]); then
            if [ $n_is_sub_upper_rim_available -eq 0 ]; then
                #echo "sub upper rim avaiable"
                array=()
                array2=()
                is_number_available 20
                if [ $? -eq 0 ]; then
                    flippables_20=$(count_flippables 20)
                fi
                is_number_available 21
                if [ $? -eq 0 ]; then
                    flippables_21=$(count_flippables 21)
                fi
                array=($flippables_20 $flippables_21)    
                array2=(20 21)
                i=0
                i_pre=0
                # multiple array loop
                position_sub_upper_rim=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position_sub_upper_rim=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
            if [ $n_is_sub_right_rim_available -eq 0 ]; then
                #echo "sub right rim avaiable"
                array=()
                array2=()
                is_number_available 30
                if [ $? -eq 0 ]; then
                    flippables_30=$(count_flippables 30)
                fi
                is_number_available 38
                if [ $? -eq 0 ]; then
                    flippables_38=$(count_flippables 38)
                fi
                array=($flippables_30 $flippables_38)    
                array2=(30 38)
                i=0
                i_pre=0
                # multiple array loop
                position_sub_right_rim=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position_sub_right_rim=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
            if [ $n_is_sub_down_rim_available -eq 0 ]; then
                #echo "sub down rim avaiable"
                array=()
                array2=()
                is_number_available 44
                if [ $? -eq 0 ]; then
                    flippables_44=$(count_flippables 44)
                fi
                is_number_available 45
                if [ $? -eq 0 ]; then
                    flippables_45=$(count_flippables 45)
                fi
                array=($flippables_44 $flippables_45)    
                array2=(44 45)
                i=0
                i_pre=0
                # multiple array loop
                position_sub_down_rim=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position_sub_down_rim=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
            if [ $n_is_sub_left_rim_available -eq 0 ]; then
                #echo "sub left rim avaiable"
                array=()
                array2=()
                is_number_available 27 
                if [ $? -eq 0 ]; then
                    flippables_27=$(count_flippables 27)
                fi
                is_number_available 35
                if [ $? -eq 0 ]; then
                    flippables_35=$(count_flippables 35)
                fi
                array=($flippables_27 $flippables_35)    
                array2=(27 35)
                i=0
                i_pre=0
                # multiple array loop
                position_sub_left_rim=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position_sub_left_rim=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
            ### Compare positions and set the position which has largest flippable number.
            if ([ $flippables_20 -ne 0 ] || [ $flippables_21 -ne 0 ] || [ $flippables_30 -ne 0 ] || [ $flippables_38 -ne 0 ] ||   
                    [ $flippables_44 -ne 0 ] || [ $flippables_45 -ne 0 ] || [ $flippables_27 -ne 0 ] || [ $flippables_35 -ne 0 ]); then    
                array=()
                array2=()
                array=($flippables_20 $flippables_21 $flippables_30 $flippables_38 $flippables_44 $flippables_45 $flippables_27 $flippables_35)    
                array2=(20 21 30 38 44 45 27 35)
                i=0
                i_pre=0
                # multiple array loop
                #position=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
        elif ([ $n_is_upper_rim_above_available -eq 0 ] || [ $n_is_right_rim_above_available -eq 0 ] || [ $n_is_down_rim_above_available -eq 0 ] || [ $n_is_left_rim_above_available -eq 0 ]); then
            if [ $n_is_upper_rim_above_available -eq 0 ]; then
                #echo "upper rim above avaiable"
                array=()
                array2=()
                is_number_available 12
                if [ $? -eq 0 ]; then
                    flippables_12=$(count_flippables 12)
                fi
                is_number_available 13
                if [ $? -eq 0 ]; then
                    flippables_13=$(count_flippables 13)
                fi
                array=($flippables_12 $flippables_13)    
                array2=(12 13)
                i=0
                i_pre=0
                # multiple array loop
                position_upper_rim_above=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position_upper_rim_above=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
            if [ $n_is_right_rim_above_available -eq 0 ]; then
                #echo "right rim above avaiable"
                array=()
                array2=()
                is_number_available 31 
                if [ $? -eq 0 ]; then
                    flippables_31=$(count_flippables 31)
                fi
                is_number_available 39 
                if [ $? -eq 0 ]; then
                    flippables_39=$(count_flippables 39)
                fi
                array=($flippables_31 $flippables_39)    
                array2=(31 39)
                i=0
                i_pre=0
                # multiple array loop
                position_right_rim_above=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position_right_rim_above=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
            if [ $n_is_down_rim_above_available -eq 0 ]; then
                #echo "down rim above avaiable"
                array=()
                array2=()
                is_number_available 52
                if [ $? -eq 0 ]; then
                    flippables_52=$(count_flippables 52)
                fi
                is_number_available 53 
                if [ $? -eq 0 ]; then
                    flippables_53=$(count_flippables 53)
                fi
                array=($flippables_52 $flippables_53)    
                array2=(52 53)
                i=0
                i_pre=0
                # multiple array loop
                position_down_rim_above=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position_down_rim_above=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
            if [ $n_is_left_rim_above_available -eq 0 ]; then
                #echo "left rim above avaiable"
                array=()
                array2=()
                is_number_available 26
                if [ $? -eq 0 ]; then
                    flippables_26=$(count_flippables 26)
                fi
                is_number_available 34
                if [ $? -eq 0 ]; then
                    flippables_34=$(count_flippables 34)
                fi
                array=($flippables_26 $flippables_34)    
                array2=(26 34)
                i=0
                i_pre=0
                # multiple array loop
                position_left_rim_above=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position_left_rim_above=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
            ### Compare positions and set the position which has largest flippable number.
            if ([ $flippables_12 -ne 0 ] || [ $flippables_13 -ne 0 ] || [ $flippables_31 -ne 0 ] || [ $flippables_39 -ne 0 ] || [ $flippables_52 -ne 0 ] ||   
                    [ $flippables_53 -ne 0 ] || [ $flippables_26 -ne 0 ] || [ $flippables_34 -ne 0 ]); then    
                array=()
                array2=()
                array=($flippables_12 $flippables_13 $flippables_31 $flippables_39 $flippables_52 $flippables_53 $flippables_26 $flippables_34)    
                array2=(12 13 31 39 52 53 26 34)
                i=0
                i_pre=0
                # multiple array loop
                #position=0
                for i in ${!array[@]};
                do
                    if [ ${array[i]} -gt $i_pre ]; then
                        position=${array2[i]}
                        i_pre=${array[i]}
                    fi
                done
            fi
        fi
    fi
    #echo "position_authentic:$position"

    if ([ $position -eq 0 ] || [ $position -eq 4 ] || [ $position -eq 5 ] || [ $position -eq 32 ] || [ $position -eq 40 ] ||
            [ $position -eq 60 ] || [ $position -eq 61 ] || [ $position -eq 25 ] || [ $position -eq 33 ]); then
        #echo "==== I check remaining positions. ===="
        local better_one=0
        better_one=1
        # corner 2nd next inner. 
        #11,14
        #23,47
        #51,54
        #18,42
        flippables_11=0
        flippables_14=0
        flippables_23=0
        flippables_47=0
        flippables_51=0
        flippables_54=0
        flippables_18=0
        flippables_42=0
        array=()
        array2=()
        is_number_available 11
        if [ $? -eq 0 ]; then
            flippables_11=$(count_flippables 11)
        fi
        is_number_available 14
        if [ $? -eq 0 ]; then
            flippables_14=$(count_flippables 14)
        fi
        is_number_available 23
        if [ $? -eq 0 ]; then
            flippables_23=$(count_flippables 23)
        fi
        is_number_available 47
        if [ $? -eq 0 ]; then
            is_flippable_safe 47
            if [ $? -eq 0 ]; then
                flippables_47=$(count_flippables 47)
            fi
        fi
        is_number_available 51
        if [ $? -eq 0 ]; then
            flippables_51=$(count_flippables 51)
        fi
        is_number_available 54
        if [ $? -eq 0 ]; then
            flippables_54=$(count_flippables 54)
        fi
        is_number_available 18 
        if [ $? -eq 0 ]; then
            flippables_18=$(count_flippables 18)
        fi
        is_number_available 42 
        if [ $? -eq 0 ]; then
            flippables_42=$(count_flippables 42)
        fi
        if ([ $flippables_11 -ne 0 ] || [ $flippables_14 -ne 0 ] || [ $flippables_23 -ne 0 ] || [ $flippables_47 -ne 0 ] || [ $flippables_51 -ne 0 ] || 
                [ $flippables_54 -ne 0 ] || [ $flippables_18 -ne 0 ] || [ $flippables_42 -ne 0 ]); then

            array=($flippables_11 $flippables_14 $flippables_23 $flippables_47 $flippables_51 $flippables_54 $flippables_18 $flippables_42)    
            array2=(11 14 23 47 51 54 18 42)    
            i=0
            i_pre=0
            # multiple array loop
            #position=${array2[0]}
            position_including_others=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_including_others=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
    fi
    #echo "position_includeing others:$position_including_others"

    # Set other positions if not in first stage when position is 0.
    if [ $position_including_others -ne 0 ]; then
        if ([ $position -eq 0 ] || [ $REMAIN -lt 20 ]); then
            position=$position_including_others
        fi
    fi
    #echo "position is set to $position"

    position_last2=0
    position_last=0

    ## TESTING IF THIS CLAUSE WORKS EVERY TIME.
    #if ([ $position -eq 0 ] || [ $MODE = "Mode2" ]); then
        #echo "XXXX I'm still checking remaining positions. XXXX"
        flippables_2=0
        flippables_7=0
        flippables_9=0
        flippables_16=0
        flippables_49=0
        flippables_56=0
        flippables_58=0
        flippables_63=0
        array=()
        array2=()
        # Next to the corner.
        #2,7
        #9,16
        #49,56
        #58,63
        is_number_available 2
        if [ $? -eq 0 ]; then
            is_number_safe 2 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                flippables_2=$(count_flippables 2)
            fi
        fi
        is_number_available 7
        if [ $? -eq 0 ]; then
            is_number_safe 7 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                flippables_7=$(count_flippables 7)
            fi
        fi
        is_number_available 9
        if [ $? -eq 0 ]; then
            is_number_safe 9 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                flippables_9=$(count_flippables 9)
            fi
        fi
        is_number_available 16
        if [ $? -eq 0 ]; then
            is_number_safe 16 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                flippables_16=$(count_flippables 16)
            fi
        fi
        is_number_available 49
        if [ $? -eq 0 ]; then
            is_number_safe 49 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                flippables_49=$(count_flippables 49)
            fi
        fi
        is_number_available 56
        if [ $? -eq 0 ]; then
            is_number_safe 56 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                flippables_56=$(count_flippables 56)
            fi
        fi
        is_number_available 58
        if [ $? -eq 0 ]; then
            is_number_safe 58 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                flippables_58=$(count_flippables 58)
            fi
        fi
        is_number_available 63 
        if [ $? -eq 0 ]; then
            is_number_safe 63 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                flippables_63=$(count_flippables 63)
            fi
        fi
        if [ -z $flippables_2 ]; then
            flippables_2=0
        fi
        if [ -z $flippables_7 ]; then
            flippables_7=0
        fi
        if [ -z $flippables_9 ]; then
            flippables_9=0
        fi
        if [ -z $flippables_16 ]; then
            flippables_16=0
        fi
        if [ -z $flippables_49 ]; then
            flippables_49=0
        fi
        if [ -z $flippables_56 ]; then
            flippables_56=0
        fi
        if [ -z $flippables_58 ]; then
            flippables_58=0
        fi
        if [ -z $flippables_63 ]; then
            flippables_63=0
        fi
        if ([ $flippables_2 -ne 0 ] || [ $flippables_7 -ne 0 ] || [ $flippables_9 -ne 0 ] || [ $flippables_16 -ne 0 ] || [ $flippables_49 -ne 0 ] || 
                [ $flippables_56 -ne 0 ] || [ $flippables_58 -ne 0 ] || [ $flippables_63 -ne 0 ]); then    
            array=($flippables_2 $flippables_7 $flippables_9 $flippables_16 $flippables_49 $flippables_56 $flippables_58 $flippables_63)    
            array2=(2 7 9 16 49 56 58 63)    
            i=0
            i_pre=0
            position_last2=0
            # multiple array loop
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_last2=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi
    #fi
    #echo "position_last2:$position_last2"

    # We prefer position_last than position_last2 when position_last2 is the last resort.
    if ([ $position_last2 -eq 0 ] || [ ! -z $LAST_RESORT ]); then
        local _safe10=1
        local _safe15=1
        local _safe50=1
        local _safe55=1
        # Next to the corner. 
        is_number_available 10
        if [ $? -eq 0 ]; then
            if !([ $position -eq 0 ] && [ $position_last2 -eq 0 ]); then
                is_number_safe 10 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    _safe10=0
                fi
            else
                # It may not be safe, but we have no other way but to take this position.
                _safe10=0
            fi
        fi
        is_number_available 15
        if [ $? -eq 0 ]; then
            if !([ $position -eq 0 ] && [ $position_last2 -eq 0 ]); then
                is_number_safe 15 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    _safe15=0
                fi
            else
                # It may not be safe, but we have no other way but to take this position.
                _safe15=0
            fi
        fi
        is_number_available 50
        if [ $? -eq 0 ]; then
            if !([ $position -eq 0 ] && [ $position_last2 -eq 0 ]); then
                is_number_safe 50 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    _safe50=0
                fi
            else
                # It may not be safe, but we have no other way but to take this position.
                _safe50=0
            fi
        fi
        is_number_available 55 
        if [ $? -eq 0 ]; then
            if !([ $position -eq 0 ] && [ $position_last2 -eq 0 ]); then
                is_number_safe 55 "${COMPUTER}"
                if [ $? -eq 0 ]; then
                    _safe55=0
                fi
            else
                # It may not be safe, but we have no other way but to take this position.
                _safe55=0
            fi
        fi

        flippables_10=0
        flippables_15=0
        flippables_50=0
        flippables_55=0
        array=()
        array2=()
        #10,15
        #50,55
        is_number_available 10
        if [ $? -eq 0 ]; then
            is_number_occupied 55 
            if [ $? -eq 0 ]; then
                flippables_10=$(count_flippables 10)
            elif [ $_safe10  -eq 0 ]; then
                flippables_10=$(count_flippables 10)
            else
                flippables_10=0
            fi
        else
            flippables_10=0
        fi
        is_number_available 15
        if [ $? -eq 0 ]; then
            is_number_occupied 50 
            if [ $? -eq 0 ]; then
                flippables_15=$(count_flippables 15)
            elif [ $_safe15  -eq 0 ]; then
                flippables_15=$(count_flippables 15)
            else
                flippables_15=0
            fi
        else
            flippables_15=0
        fi
        is_number_available 50
        if [ $? -eq 0 ]; then
            is_number_occupied 15 
            if [ $? -eq 0 ]; then
                flippables_50=$(count_flippables 50)
            elif [ $_safe50  -eq 0 ]; then
                flippables_50=$(count_flippables 50)
            else
                flippables_50=0
            fi
        else
            flippables_50=0
        fi
        is_number_available 55
        if [ $? -eq 0 ]; then
            is_number_occupied 10 
            if [ $? -eq 0 ]; then
                flippables_55=$(count_flippables 55)
            elif [ $_safe55  -eq 0 ]; then
                flippables_55=$(count_flippables 55)
            else
                flippables_55=0
            fi
        else
            flippables_55=0
        fi
        if [ -z $flippables_10 ]; then
            flippables_10=0
        fi
        if [ -z $flippables_15 ]; then
            flippables_15=0
        fi
        if [ -z $flippables_50 ]; then
            flippables_50=0
        fi
        if [ -z $flippables_55 ]; then
            flippables_55=0
        fi
        if ([ $flippables_10 -ne 0 ] || [ $flippables_15 -ne 0 ] || [ $flippables_50 -ne 0 ] || [ $flippables_55 -ne 0 ]); then    
            array=($flippables_10 $flippables_15 $flippables_50 $flippables_55)    
            array2=(10 15 50 55)    
            i=0
            i_pre=0
            # multiple array loop
            position_last=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_last=${array2[i]}
                    i_pre=${array[i]}
                fi
            done
        fi

    fi
    #echo "position_last:$position_last"
    # Still 'position' is 0.

    if [ $position -eq 0 ]; then
        if ([ $position_last2 -ne 0 ] || [ $position_last -ne 0 ]); then
            if [ $position_last2 -gt $position_last ]; then
                position=$position_last2
            else
                position=$position_last
            fi
        fi
    fi
    #echo "##position:$position"

    # Go aggressive if safe.
    if [ "${MODE}" = "Mode2" ]; then
        #if [ $position -eq 0 ]; then
            is_corner_available
            if [ $? -eq 1 ]; then
                opponent_exists_in_rim "${HUMAN}"
                if [ $? -eq 1 ]; then
                    if [ $position_last2 -ne 0 ]; then
                        echo "I go aggressive."
                        position=$position_last2
                    fi
                fi
            fi
        #fi
        ###FIXME:
        is_number_available 4 
        if [ $? -eq 0 ]; then
            is_number_safe 4 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggresive=4
            fi
        fi
        is_number_available 5 
        if [ $? -eq 0 ]; then
            is_number_safe 5 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=5
            fi
        fi
        is_number_available 60 
        if [ $? -eq 0 ]; then
            is_number_safe 60 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=60
            fi
        fi
        is_number_available 61
        if [ $? -eq 0 ]; then
            is_number_safe 61 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=61
            fi
        fi
        is_number_available 25 
        if [ $? -eq 0 ]; then
            is_number_safe 25 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=25
            fi
        fi
        is_number_available 33 
        if [ $? -eq 0 ]; then
            is_number_safe 33 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=33
            fi
        fi
        is_number_available 32 
        if [ $? -eq 0 ]; then
            is_number_safe 32 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=32
            fi
        fi
        is_number_available 40
        if [ $? -eq 0 ]; then
            is_number_safe 40 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=40
            fi
        fi
        is_number_available 62
        if [ $? -eq 0 ]; then
            is_number_safe 62 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=62
            fi
        fi

        # we check these and find AGGRESSIVE_SAVE.
        is_number_available 17
        if [ $? -eq 0 ]; then
            is_number_safe 17 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=17
            fi
        fi
        is_number_available 41
        if [ $? -eq 0 ]; then
            is_number_safe 41 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=41
            fi
        fi
        is_number_available 24
        if [ $? -eq 0 ]; then
            is_number_safe 24 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=24
            fi
        fi
        is_number_available 48
        if [ $? -eq 0 ]; then
            is_number_safe 48 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=48
            fi
        fi
        is_number_available 3
        if [ $? -eq 0 ]; then
            is_number_safe 3 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=3
            fi
        fi
        is_number_available 6
        if [ $? -eq 0 ]; then
            is_number_safe 6 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=6
            fi
        fi
        is_number_available 59
        if [ $? -eq 0 ]; then
            is_number_safe 59 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=59
            fi
        fi
        is_number_available 62
        if [ $? -eq 0 ]; then
            is_number_safe 62 "${COMPUTER}"
            if [ $? -eq 0 ]; then
                position_aggressive=62
            fi
        fi
    fi
    #echo "#position_aggressive:$position_aggressive"

    # We select safest option.
    if [ $SAFEST -ne 0 ]; then
        position=$SAFEST
        SAFEST=0
    fi
    # We select priority option.
    if [ $PRIORITY -ne 0 ]; then
        position=$PRIORITY
        PRIORITY=0
    fi

    # Lastly we select best option.
    if [ $EMERGENCY -eq 0 ]; then
        position=$position_last2
    fi

    # Lastly we select best option even the corner is available.
    if ([ $position_reliable_than_corner -ne 0 ] && [ $LAST_RESORT -eq 0 ]); then
        #echo "position_reliable_than_corner:$position_reliable_than_corner"
        if [ $CORNER_PRIORITY -eq 1 ]; then
            CORNER_PRIORITY=0
        else
            position=$position_reliable_than_corner
        fi
    fi

    # We seek best option.
    local _check_flippable12=""
    local _check_flippable13=""
    local _check_flippable26=""
    local _check_flippable27=""
    local _check_flippable31=""
    local _check_flippable39=""
    _check_flippable12=$(get_contents_flippables 12 | grep "28#\|36#")
    _check_flippable13=$(get_contents_flippables 13 | grep "29#\|37#")
    _check_flippable52=$(get_contents_flippables 52 | grep "28#\|36#")
    _check_flippable53=$(get_contents_flippables 53 | grep "29#\|37#")
    _check_flippable26=$(get_contents_flippables 26 | grep "28#\|29#")
    _check_flippable34=$(get_contents_flippables 34 | grep "36#\|37#")
    _check_flippable31=$(get_contents_flippables 31 | grep "28#\|29#")
    _check_flippable39=$(get_contents_flippables 39 | grep "36#\|37#")
    ###FIXME
    if [ ! -z "${_check_flippable12}" ]; then
        position=12
    elif [ ! -z "${_check_flippable13}" ]; then
        position=13
    elif [ ! -z "${_check_flippable52}" ]; then
        position=52
    elif [ ! -z "${_check_flippable53}" ]; then
        position=53
    elif [ ! -z "${_check_flippable26}" ]; then
        position=26
    elif [ ! -z "${_check_flippable34}" ]; then
        position=34
    elif [ ! -z "${_check_flippable31}" ]; then
        position=31
    elif [ ! -z "${_check_flippable39}" ]; then
        position=39
    fi
    # end:We seek best option.

    # Anyway we select probably the best option.
    if [ $PROBABLY_BEST -ne 0 ]; then
        position=$PROBABLY_BEST
        PROBABLY_BEST=0
    fi
    # xx
    if ([ "${MODE}" = "Mode2" ] && [ $position_aggressive -ne 0 ]); then
        position=$position_aggressive
    fi
    # xx
    if ([ "${MODE}" = "Mode2" ] && [ $AGGRESSIVE_SAVE -ne 0 ]); then
        position=$AGGRESSIVE_SAVE
        AGGRESSIVE_SAVE=0
    fi
    #echo "#position_final:$position"

    if [ $position -eq 0 ]; then
        COMPUTER_PASS=1
        PASS_ALL=$((PASS_ALL + 1))
        echo "I pass." >&2
        return 1
    fi

    local _first
    local _second 
    if [ $human -eq 0 ]; then
        _first=$((position % 8))
        if [ $_first -eq 0 ]; then
            _first="h"
        elif [ $_first -eq 1 ]; then
            _first="a"
        elif [ $_first -eq 2 ]; then
            _first="b"
        elif [ $_first -eq 3 ]; then
            _first="c"
        elif [ $_first -eq 4 ]; then
            _first="d"
        elif [ $_first -eq 5 ]; then
            _first="e"
        elif [ $_first -eq 6 ]; then
            _first="f"
        elif [ $_first -eq 7 ]; then
            _first="g"
        fi
        _second=$((position / 8))
        if [ ! "${_first}" = "h" ]; then
            _second=$((_second + 1))
        fi
        echo "Position: $_first$_second"
        place_and_flip $position "${color}"
    fi
    return 0
}

## This function counts black and white.
## var1: 1 only count and return.

function count_black_and_white()
{
    local only_count=0
    local black=0
    local white=0
    local remain=0
    local count_all=0
    local pattern_b="B"
    local pattern_w="W"
    if [ ! -z "${1}" ]; then
        only_count=1    
    fi
    black=$(awk -F" " -v pat="$pattern_b" '{for(i=1;i<=NF;i++) if($i ~ pat) c++} END {print c}' "${FILE_KIFU_PRESENT}")
    white=$(awk -F" " -v pat="$pattern_w" '{for(i=1;i<=NF;i++) if($i ~ pat) c++} END {print c}' "${FILE_KIFU_PRESENT}")
    remain=$((64 - $black - $white))

    # Note that 'remain(local)' and 'REMAIN(global)' is different.
    count_all=$((black + white))
    REMAIN=$((64 - count_all))
    if [ $only_count -eq 1 ]; then
        return 0
    fi
    echo "Black:$black White:$white Remain:$remain"
    if ([ $count_all -eq 64 ] || [ $PASS_ALL -eq 3 ]); then
        if [ $black -gt $white ]; then
            if [ "${HUMAN}" = "Black" ]; then
                echo "You (Black) won."
            else
                echo "Computer (Black) won."
            fi
        elif [ $black -eq $white ]; then
            echo "Tie."
        else
            if [ "${HUMAN}" = "White" ]; then
                echo "You (White) won."
            else
                echo "Computer (White) won."
            fi
        fi
        echo "Game ends."
        exit 0
    fi
}

## Main Part
##

echo ""
echo "CLI_Othello ver3.7"
echo "  a  b  c  d  e  f  g  h" > "${FILE}"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - W B - - - - - - B W - - - - - - - - - - - - - - - - - - - - - - - - - - -" > "${FILE_KIFU_PRESENT}"
check_file

PS3="Start game?"
select answer in Black White No
do
    if [ -n "${answer}" ]; then
        case "${REPLY}" in
            1)  HUMAN="Black"
                COMPUTER="White"
                break
                ;;
            2)  HUMAN="White"
                COMPUTER="Black"
                break
                ;;
            3) exit 1 ;;
            *) echo "Invalid." ;;
        esac
    else
        echo "Invalid."
    fi
done

echo ""
echo "You are ${HUMAN}"
echo ""
echo "Mode"

PS3="Select mode:"
select answer in Normal Mode2
do
    if [ -n "${answer}" ]; then
        case "${REPLY}" in
            1)  MODE="Normal"
                echo ""
                echo "I'm in 'Normal mode'."
                echo ""
                break
                ;;
            2)  MODE="Mode2"
                echo ""
                echo "I'm in 'Mode2 (Aggressive)'."
                echo ""
                break
                ;;
            3) exit 1 ;;
            *) echo "Invalid." ;;
        esac
    else
        echo "Invalid."
    fi
done

show_kifu_present

echo "You are ${HUMAN}"
while :
do
    count_black_and_white 1
    if [ "${HUMAN}" = "White" ]; then
        # Computer
        echo "I'm Black. Thinking..."
        search_available_positions "Black" 
        COMPUTER_PASS=0
        judge_position "Black" 0
       	show_kifu_present
        count_black_and_white
        # Human 
        search_available_positions "White" 
        echo "Your turn."
        HUMAN_PASS=0
        get_position_value
        while :
        do
            is_number_available $POSITION
            if [ $? -eq 0 ]; then
                break
            else
                if [ -z "${AVAILABLE_ALL[*]}" ]; then
                    echo "You pass."
                    HUMAN_PASS=1 
                    break
                fi
                get_position_value
            fi
        done
        if [ $HUMAN_PASS -eq 0 ]; then
            judge_position "White" 1
            place_and_flip $POSITION "White"
            show_kifu_present
            count_black_and_white
        fi
    else
        ## Human 
        search_available_positions "Black" 
        echo "Your turn."
        HUMAN_PASS=0
        get_position_value
        while :
        do
            is_number_available $POSITION
            if [ $? -eq 0 ]; then
                break
            else
                if [ -z "${AVAILABLE_ALL[*]}" ]; then
                    echo "You pass."
                    HUMAN_PASS=1 
                    break
                fi
                get_position_value
            fi
        done
        if [ $HUMAN_PASS -eq 0 ]; then
            judge_position "Black" 1
            place_and_flip $POSITION "Black"
            show_kifu_present
            count_black_and_white
        fi
        # Computer
        echo "I'm White. Thinking..."
        search_available_positions "White" 
        COMPUTER_PASS=0
        judge_position "White" 0
        if [ $COMPUTER_PASS -eq 1 ]; then
            if [ $HUMAN_PASS -eq 1 ]; then
                PASS_ALL=$((PASS_ALL + 1))
                count_black_and_white
                exit 0
            fi
            continue
        fi
       	show_kifu_present
        count_black_and_white
    fi
done

exit 0
