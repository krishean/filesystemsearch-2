#!/usr/bin/env bash
if [ -z "$GITHUB_WORKSPACE" ];then GITHUB_WORKSPACE=$(dirname "$(realpath "$0")");fi
cd "$GITHUB_WORKSPACE"
#echo "GITHUB_WORKSPACE=$GITHUB_WORKSPACE"

UNAME_S=$(uname -s)
if [ "$UNAME_S" == "Darwin" ];then
    UNAME_O="Darwin"
else
    UNAME_O=$(uname -o)
fi

# get the latest version of sqlite
SQLITE_VER="3440200"
SQLITE_DIR="sqlite-amalgamation-${SQLITE_VER}"
SQLITE_ZIP="${SQLITE_DIR}.zip"
SQLITE_URL="https://sqlite.org/2023/${SQLITE_ZIP}"

if [ "$UNAME_S" == "Linux" ];then
    # install prereqs:
    #sudo apt-get install git make build-essential libsqlite3-dev
    PKGS="git make build-essential libsqlite3-dev"
    REQS=()
    for PKG in $PKGS;do
        dpkg -s $PKG &> /dev/null
        if [ $? -eq 1 ];then
            REQS+=($PKG)
        fi
    done
    if (( ${#REQS[@]} ));then
        echo -e "Please install prerequisite packages:\nsudo apt-get install ${REQS[*]}\n"
        exit
    fi
elif [[ "$UNAME_S" =~ ^MINGW32_NT.* ]];then # check for required 32-bit packages
    # note: 32-bit libsqlite3-0.dll is also dependant on libgcc_s_dw2-1.dll
    # and libgcc_s_dw2-1.dll is dependant on libwinpthread-1.dll
    # this defeats the purpose of static linking libgcc and libpthread
    # mingw-w64-i686-sqlite3
    PKGS="git make unzip curl mingw-w64-i686-curl mingw-w64-i686-gcc"
    REQS=()
    for PKG in $PKGS;do
        #if pacman -Qs $PKG > /dev/null;then
        if ! pacman -Q $PKG>/dev/null 2>&1;then
            REQS+=($PKG)
        fi
    done
    if (( ${#REQS[@]} ));then
        echo -e "Please install prerequisite packages:\npacman -S ${REQS[*]}\n"
        exit
    fi
    # get sqlite3.h and unzip to src/
    if [ ! -f "${SQLITE_ZIP}" ];then curl -LO "${SQLITE_URL}";fi
    unzip -j -d src/ -o "${SQLITE_ZIP}" "${SQLITE_DIR}/sqlite3.h"
    if [ ! -d bin ];then mkdir -pv bin;fi
    # get sqlite3.dll and unzip to bin/
    SQLITE_ZIP="sqlite-dll-win-x86-${SQLITE_VER}.zip"
    SQLITE_URL="https://sqlite.org/2023/${SQLITE_ZIP}"
    if [ ! -f "${SQLITE_ZIP}" ];then curl -LO "${SQLITE_URL}";fi
    unzip -j -d bin/ -o "${SQLITE_ZIP}" "sqlite3.dll"
elif [[ "$UNAME_S" =~ ^MINGW64_NT.* ]];then # check for required 64-bit packages
    # mingw-w64-x86_64-sqlite3
    PKGS="git make unzip curl mingw-w64-x86_64-curl mingw-w64-x86_64-gcc"
    REQS=()
    for PKG in $PKGS;do
        #if pacman -Qs $PKG > /dev/null;then
        if ! pacman -Q $PKG>/dev/null 2>&1;then
            REQS+=($PKG)
        fi
    done
    if (( ${#REQS[@]} ));then
        echo -e "Please install prerequisite packages:\npacman -S ${REQS[*]}\n"
        exit
    fi
    # get sqlite3.h and unzip to src/
    if [ ! -f "${SQLITE_ZIP}" ];then curl -LO "${SQLITE_URL}";fi
    unzip -j -d src/ -o "${SQLITE_ZIP}" "${SQLITE_DIR}/sqlite3.h"
    if [ ! -d bin ];then mkdir -pv bin;fi
    # get sqlite3.dll and unzip to bin/
    SQLITE_ZIP="sqlite-dll-win-x64-${SQLITE_VER}.zip"
    SQLITE_URL="https://sqlite.org/2023/${SQLITE_ZIP}"
    if [ ! -f "${SQLITE_ZIP}" ];then curl -LO "${SQLITE_URL}";fi
    unzip -j -d bin/ -o "${SQLITE_ZIP}" "sqlite3.dll"
fi

make clean && make strip
ret=$?

echo "Done."
exit $ret
