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

FILE="1.txt"
FILE_KIFU_PRESENT="./data/kifu_present.txt"

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

HUMAN=""
ALPHABET=""
NUMBER=""
POSITION=""
SELECTED=""

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
            if [ $_check_str != "${color}" ]; then
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
            AVAILABLE_NO1+=("${position}:${position}")
            _available=1
        fi
        FLIPPABLE_NO1+=("${position}:${position_chk}")
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
            AVAILABLE_NO2+=("${position}:${position}")
            _available=1
        fi
        FLIPPABLE_NO2+=("${position}:${position_calc}")
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
            AVAILABLE_NO3+=("${position}:${position}")
            _available=1
        fi
        FLIPPABLE_NO3+=("${position}:${position_calc}")
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
            AVAILABLE_NO4+=("${position}:${position}")
            _available=1
        fi
        FLIPPABLE_NO4+=("${position}:${position_calc}")
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
            if [ $_check_str != "${color}" ]; then
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
            AVAILABLE_NO5+=("${position}:${position}")
            _available=1
        fi
        FLIPPABLE_NO5+=("${position}:${position_chk}")
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
            AVAILABLE_NO6+=("${position}:${position}")
            _available=1
        fi
        FLIPPABLE_NO6+=("${position}:${position_calc}")
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
            AVAILABLE_NO7+=("${position}:${position}")
            _available=1
        fi
        FLIPPABLE_NO7+=("${position}:${position_calc}")
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
            AVAILABLE_NO8+=("${position}:${position}")
            _available=1
        fi
        FLIPPABLE_NO8+=("${position}:${position_calc}")
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
    local i=1

    if [ "${teban}" = "White" ]; then
        color="W"
    elif [ "${teban}" = "Black" ]; then
        color="B"
    fi

    AVAILABLE_ALL=("" )
    FLIPPABLE_ALL=("")

    AVAILABLE_NO1_ALL=("")
    AVAILABLE_NO2_ALL=("" )
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
## var1: number
##

function is_number_available()
{
    if [ -z "${1}" ]; then
        echo "Please give a variable as a number." >&2
        exit 1
    fi
    local num="${1}" 
    # Try to match when only one member and not forget last one.
    num_str=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*${num}:[[:digit:]]\+.*") 
    if [ -z "${num_str}" ]; then
        return 1
    fi
    return 0
}

## This function returns 0 if corner is available.
##

function is_corner_available()
{
    num_1=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*1:1.*")
    num_8=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*8:8.*")
    num_57=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*57:57.*")
    num_64=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*64:64.*")
    if ([ -z "${num_1}" ] && [ -z "${num_8}" ] && [ -z "${num_57}" ] && [ -z "${num_64}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-corner is available.
##

function is_sub_corner_available()
{
    num_19=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*19:19.*")
    num_22=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*22:22.*")
    num_43=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*43:43.*")
    num_46=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*46:46.*")
    if ([ -z "${num_19}" ] && [ -z "${num_22}" ] && [ -z "${num_43}" ] && [ -z "${num_46}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if upper rim is available.
##

function is_upper_rim_available()
{
    num_3=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*3:3.*")
    num_4=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*4:4.*")
    num_5=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*5:5.*")
    num_6=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*6:6.*")
    if ([ -z "${num_3}" ] && [ -z "${num_4}" ] && [ -z "${num_5}" ] && [ -z "${num_6}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if right rim is available.
##

function is_right_rim_available()
{
    num_24=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*24:24.*")
    num_32=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*32:32.*")
    num_40=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*40:40.*")
    num_48=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*48:48.*")
    if ([ -z "${num_24}" ] && [ -z "${num_32}" ] && [ -z "${num_40}" ] && [ -z "${num_48}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if down rim is available.
##

function is_down_rim_available()
{
    num_59=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*59:59.*")
    num_60=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*60:60.*")
    num_61=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*61:61.*")
    num_62=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*62:62.*")
    if ([ -z "${num_59}" ] && [ -z "${num_60}" ] && [ -z "${num_61}" ] && [ -z "${num_62}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if left rim is available.
##

function is_left_rim_available()
{
    num_17=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*17:17.*")
    num_25=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*25:25.*")
    num_33=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*33:33.*")
    num_41=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*41:41.*")
    if ([ -z "${num_17}" ] && [ -z "${num_25}" ] && [ -z "${num_33}" ] && [ -z "${num_41}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-upper rim is available.
##

function is_sub_upper_rim_available()
{
    num_20=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*20:20.*")
    num_21=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*21:21.*")
    if ([ -z "${num_20}" ] && [ -z "${num_21}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-right rim is available.
##

function is_sub_right_rim_available()
{
    num_30=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*30:30.*")
    num_38=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*38:38.*")
    if ([ -z "${num_30}" ] && [ -z "${num_38}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-down rim is available.
##

function is_sub_down_rim_available()
{
    num_44=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*44:44.*")
    num_45=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*45:45.*")
    if ([ -z "${num_44}" ] && [ -z "${num_45}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if sub-left rim is available.
##

function is_sub_left_rim_available()
{
    num_27=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*27:27.*")
    num_35=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*35:35.*")
    if ([ -z "${num_27}" ] && [ -z "${num_35}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if upper rim-above is available.
##

function is_upper_rim_above_available()
{
    num_12=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*12:12.*")
    num_13=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*13:13.*")
    if ([ -z "${num_12}" ] && [ -z "${num_13}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if right rim-above is available.
##

function is_right_rim_above_available()
{
    num_31=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*31:31.*")
    num_39=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*39:39.*")
    if ([ -z "${num_31}" ] && [ -z "${num_39}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if down rim-above is available.
##

function is_down_rim_above_available()
{
    num_52=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*52:52.*")
    num_53=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*53:53.*")
    if ([ -z "${num_52}" ] && [ -z "${num_53}" ]); then
        return 1
    fi
    return 0
}

## This function returns 0 if left rim-above is available.
##

function is_left_rim_above_available()
{
    num_26=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*26:26.*")
    num_34=$(echo "${AVAILABLE_ALL[*]}" | grep -e ".*34:34.*")
    if ([ -z "${num_26}" ] && [ -z "${num_34}" ]); then
        return 1
    fi
    return 0
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
    number="^${num}:" 
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
    number="^${num}:" 
    number_v="${num}:" 
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
    #echo "${AVAILABLE_ALL[*]}"
    is_corner_available
    n_is_corner_available=$?
    is_sub_corner_available
    n_is_sub_corner_available=$?
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
            flippables_1=$(count_flippables 1)
        fi
        is_number_available 8
        if [ $? -eq 0 ]; then
            flippables_8=$(count_flippables 8)
        fi
        is_number_available 57
        if [ $? -eq 0 ]; then
            flippables_57=$(count_flippables 57)
        fi
        is_number_available 64
        if [ $? -eq 0 ]; then
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
            fi
            i_pre=${array[i]}
        done
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
            position=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position=${array2[i]}
                fi
                i_pre=${array[i]}
            done
        fi
    elif ([ $n_is_sub_upper_rim_available -eq 0 ] || [ $n_is_sub_right_rim_available -eq 0 ] || [ $n_is_sub_down_rim_available -eq 0 ] || [ $n_is_sub_left_rim_available -eq 0 ]); then
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
                fi
                i_pre=${array[i]}
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
                fi
                i_pre=${array[i]}
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
                fi
                i_pre=${array[i]}
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
                fi
                i_pre=${array[i]}
            done
        fi
        ### Compare positions and set the position which has largest flippable number.
        if [ -z $position_sub_upper_rim ]; then
            position_sub_upper_rim=0   
        fi
        if [ -z $position_sub_right_rim ]; then
            position_sub_right_rim=0   
        fi
        if [ -z $position_sub_down_rim ]; then
            position_sub_down_rim=0   
        fi
        if [ -z $position_sub_left_rim ]; then
            position_sub_left_rim=0   
        fi
        array=($position_sub_upper_rim $position_sub_right_rim $position_sub_down_rim $position_sub_left_rim)    
        i=0
        i_pre=0
        # Note that here we do normal description.
        position=0
        for i in ${array[@]}
        do
            if [ $i -gt $i_pre ]; then
                position=$i
            fi
            i_pre=$i
        done
    elif ([ $n_is_upper_rim_available -eq 0 ] || [ $n_is_right_rim_available -eq 0 ] || [ $n_is_down_rim_available -eq 0 ] || [ $n_is_left_rim_available -eq 0 ]); then
        if [ $n_is_upper_rim_available -eq 0 ]; then
            #echo "upper rim avaiable"
            array=()
            array2=()
            is_number_available 3
            if [ $? -eq 0 ]; then
                flippables_3=$(count_flippables 3)
            fi
            is_number_available 4
            if [ $? -eq 0 ]; then
                flippables_4=$(count_flippables 4)
            fi
            is_number_available 5
            if [ $? -eq 0 ]; then
                flippables_5=$(count_flippables 5)
            fi
            is_number_available 6
            if [ $? -eq 0 ]; then
                flippables_6=$(count_flippables 6)
            fi
            array=($flippables_3 $flippables_4 $flippables_5 $flippables_6)    
            array2=(3 4 5 6)
            i=0
            i_pre=0
            # multiple array loop
            position_upper_rim=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_upper_rim=${array2[i]}
                fi
                i_pre=${array[i]}
            done
        fi
        # Here, not elif but if. Same below.
        if [ $n_is_right_rim_available -eq 0 ]; then
            #echo "right rim avaiable"
            array=()
            array2=()
            is_number_available 24
            if [ $? -eq 0 ]; then
                flippables_24=$(count_flippables 24)
            fi
            is_number_available 32
            if [ $? -eq 0 ]; then
                flippables_32=$(count_flippables 32)
            fi
            is_number_available 40
            if [ $? -eq 0 ]; then
                flippables_40=$(count_flippables 40)
            fi
            is_number_available 48
            if [ $? -eq 0 ]; then
                flippables_48=$(count_flippables 48)
            fi
            array=($flippables_24 $flippables_32 $flippables_40 $flippables_48)    
            array2=(24 32 40 48)
            i=0
            i_pre=0
            # multiple array loop
            position_right_rim=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_right_rim=${array2[i]}
                fi
                i_pre=${array[i]}
            done
        fi
        if [ $n_is_down_rim_available -eq 0 ]; then
            #echo "down rim avaiable"
            array=()
            array2=()
            is_number_available 59
            if [ $? -eq 0 ]; then
                flippables_59=$(count_flippables 59)
            fi
            is_number_available 60
            if [ $? -eq 0 ]; then
                flippables_60=$(count_flippables 60)
            fi
            is_number_available 61
            if [ $? -eq 0 ]; then
                flippables_61=$(count_flippables 61)
            fi
            is_number_available 62
            if [ $? -eq 0 ]; then
                flippables_62=$(count_flippables 62)
            fi
            array=($flippables_59 $flippables_60 $flippables_61 $flippables_62)    
            array2=(59 60 61 62)
            i=0
            i_pre=0
            # multiple array loop
            position_down_rim=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_down_rim=${array2[i]}
                fi
                i_pre=${array[i]}
            done
        fi
        if [ $n_is_left_rim_available -eq 0 ]; then
            #echo "left rim avaiable"
            array=()
            array2=()
            is_number_available 17
            if [ $? -eq 0 ]; then
                flippables_17=$(count_flippables 17)
            fi
            is_number_available 25
            if [ $? -eq 0 ]; then
                flippables_25=$(count_flippables 25)
            fi
            is_number_available 33
            if [ $? -eq 0 ]; then
                flippables_33=$(count_flippables 33)
            fi
            is_number_available 41
            if [ $? -eq 0 ]; then
                flippables_41=$(count_flippables 41)
            fi
            array=($flippables_17 $flippables_25 $flippables_33 $flippables_41)    
            array2=(17 25 33 41)
            i=0
            i_pre=0
            # multiple array loop
            position_left_rim=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position_left_rim=${array2[i]}
                fi
                i_pre=${array[i]}
            done
        fi
        ### Compare positions and set the position which has largest flippable number.
        if [ -z $position_upper_rim ]; then
            position_upper_rim=0
        fi
        if [ -z $position_right_rim ]; then
            position_right_rim=0
        fi
        if [ -z $position_down_rim ]; then
            position_down_rim=0
        fi
        if [ -z $position_left_rim ]; then
            position_left_rim=0
        fi
        array=($position_upper_rim $position_right_rim $position_down_rim $position_left_rim)    
        i=0
        i_pre=0
        # Note that here we do normal description.
	position=0
        for i in ${array[@]}
        do
            if [ $i -gt $i_pre ]; then
                position=$i
            fi
            i_pre=$i
        done
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
            #is_number_available 14
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
                fi
                i_pre=${array[i]}
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
            #is_number_available 47 
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
                fi
                i_pre=${array[i]}
            done
        fi
        if [ $n_is_down_rim_above_available -eq 0 ]; then
            # debug
            #echo "down rim above avaiable"
            # end debug
            array=()
            array2=()
            is_number_available 51
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
                fi
                i_pre=${array[i]}
            done
        fi
        if [ $n_is_left_rim_above_available -eq 0 ]; then
            # debug
            #echo "left rim above avaiable"
            # end debug
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
            #is_number_available 42
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
                fi
                i_pre=${array[i]}
            done
        fi
        ### Compare positions and set the position which has largest flippable number.
        if [ -z $position_upper_rim_above ]; then
            position_upper_rim_above=0
        fi
        if [ -z $position_right_rim_above ]; then
            position_right_rim_above=0
        fi
        if [ -z $position_down_rim_above ]; then
            position_down_rim_above=0
        fi
        if [ -z $position_left_rim_above ]; then
            position_left_rim_above=0
        fi
        array=($position_upper_rim_above $position_right_rim_above $position_down_rim_above $position_left_rim_above)    
        i=0
        i_pre=0
        # Note that here we do normal description.
        position=0
        for i in ${array[@]}
        do
            if [ $i -gt $i_pre ]; then
                position=$i
            fi
            i_pre=$i
        done
    fi

    if [ $position -eq 0 ]; then
    #if ([ $position -eq 0 ] || [ $MODE = "Aggressive" ]); then
        #echo "==== I check remaining positions. ===="
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
            flippables_47=$(count_flippables 47)
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
            position=0
            for i in ${!array[@]};
            do
                if [ ${array[i]} -gt $i_pre ]; then
                    position=${array2[i]}
                fi
                i_pre=${array[i]}
            done
        fi
    fi

    position_last2=0
    position_last=0
    #if [ $position -eq 0 ]; then
    if ([ $position -eq 0 ] || [ $MODE = "Aggressive" ]); then
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
            flippables_2=$(count_flippables 2)
        fi
        is_number_available 7
        if [ $? -eq 0 ]; then
            flippables_7=$(count_flippables 7)
        fi
        is_number_available 9
        if [ $? -eq 0 ]; then
            flippables_9=$(count_flippables 9)
        fi
        is_number_available 16
        if [ $? -eq 0 ]; then
            flippables_16=$(count_flippables 16)
        fi
        is_number_available 49
        if [ $? -eq 0 ]; then
            flippables_49=$(count_flippables 49)
        fi
        is_number_available 56
        if [ $? -eq 0 ]; then
            flippables_56=$(count_flippables 56)
        fi
        is_number_available 58
        if [ $? -eq 0 ]; then
            flippables_58=$(count_flippables 58)
        fi
        is_number_available 63 
        if [ $? -eq 0 ]; then
            flippables_63=$(count_flippables 63)
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
                fi
                i_pre=${array[i]}
            done
        fi
echo "position_last2:$position_last2"
    fi

    if [ $position_last2 -eq 0 ]; then
        # Next to the corner. 
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
            flippables_10=$(count_flippables 10)
        fi
        is_number_available 15
        if [ $? -eq 0 ]; then
            flippables_15=$(count_flippables 15)
        fi
        is_number_available 50
        if [ $? -eq 0 ]; then
            flippables_50=$(count_flippables 50)
        fi
        is_number_available 55
        if [ $? -eq 0 ]; then
            flippables_55=$(count_flippables 55)
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
                fi
                i_pre=${array[i]}
            done
        fi
    fi
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

    # Aggressive mode
    flippables_aggressive=$(count_flippables $position_last2)
    if [ $flippables_aggressive -ge 4 ]; then
        echo "flippables_aggressive:$flippables_aggressive"
        echo "I go aggressive!"
        position=$position_last2
    fi

    if [ $position -eq 0 ]; then
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
##

function count_black_and_white()
{
    local black=0
    local white=0
    local count_all=0
    local pattern_b="B"
    local pattern_w="W"
    black=$(awk -F" " -v pat="$pattern_b" '{for(i=1;i<=NF;i++) if($i ~ pat) c++} END {print c}' "${FILE_KIFU_PRESENT}")
    white=$(awk -F" " -v pat="$pattern_w" '{for(i=1;i<=NF;i++) if($i ~ pat) c++} END {print c}' "${FILE_KIFU_PRESENT}")
    echo "Black:$black White:$white"
    count_all=$((black + white))
    if [ $count_all -eq 64 ]; then
        if [ $black -gt $white ]; then
            echo "Black wins."
        elif [ $black -eq $white ]; then
            echo "Tie."
        else
            echo "White wins."
        fi
        echo "Game ends."
        exit 0
    fi
}

## Main Part
##

echo ""
echo "CLI_Othello ver0.3"
echo "  a  b  c  d  e  f  g  h" > "${FILE}"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - W B - - - - - - B W - - - - - - - - - - - - - - - - - - - - - - - - - - -" > "${FILE_KIFU_PRESENT}"
check_file

PS3="Start game?"
select answer in Black White No
do
    if [ -n "${answer}" ]; then
        case "${REPLY}" in
            1)  HUMAN="Black"
                #show_kifu_present
                break
                ;;
            2)  HUMAN="White"
                #show_kifu_present
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
select answer in Normal Aggressive 
do
    if [ -n "${answer}" ]; then
        case "${REPLY}" in
            1)  MODE="Normal"
                echo ""
                echo "I'm in 'Normal mode'."
                echo ""
                break
                ;;
            2)  MODE="Aggressive"
                echo ""
                echo "I'm in 'Aggressive mode'."
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
    if [ "${HUMAN}" = "White" ]; then
        # Computer
        echo "I'm Black. Thinking..."
        search_available_positions "Black" 
        if [ $? -eq 2 ]; then
            echo "Game ends."
            exit 0
        fi
        judge_position "Black" 0
       	show_kifu_present
        count_black_and_white
        # Human 
        search_available_positions "White" 
        if [ $? -eq 2 ]; then
            echo "Game ends."
            exit 0
        fi
        echo "Your turn."
        get_position_value
        while :
        do
            is_number_available $POSITION
            if [ $? -eq 0 ]; then
                break
            else
                get_position_value
            fi
        done
        judge_position "White" 1
        place_and_flip $POSITION "White"
        show_kifu_present
        count_black_and_white
    else
        ## Human 
        search_available_positions "Black" 
        if [ $? -eq 2 ]; then
            echo "Game ends."
            exit 0
        fi
        echo "Your turn."
        get_position_value
        while :
        do
            is_number_available $POSITION
            if [ $? -eq 0 ]; then
                break
            else
                get_position_value
            fi
        done
        judge_position "Black" 1
        place_and_flip $POSITION "Black"
        show_kifu_present
        count_black_and_white
        # Computer
        echo "I'm White. Thinking..."
        search_available_positions "White" 
        if [ $? -eq 2 ]; then
            echo "Game ends."
            exit 0
        fi
        judge_position "White" 0
       	show_kifu_present
        count_black_and_white
    fi
done

exit 0
