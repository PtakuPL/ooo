# Install script for directory: /home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/include-what-you-use" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/include-what-you-use")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/include-what-you-use"
         RPATH "\$ORIGIN/../lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/home/ptaku/serweryt/Tibia/silnik/iwyu/build/bin/include-what-you-use")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/include-what-you-use" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/include-what-you-use")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/include-what-you-use"
         OLD_RPATH "\$ORIGIN/../lib:/usr/lib/llvm-18/lib:/usr/lib/llvm-14/lib:"
         NEW_RPATH "\$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/include-what-you-use")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE PROGRAM FILES
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/fix_includes.py"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/iwyu_tool.py"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/include-what-you-use" TYPE FILE FILES
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/boost-1.64-all-private.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/boost-1.64-all.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/boost-1.75-all-private.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/boost-1.75-all.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/boost-all-private.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/boost-all.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/clang-6.intrinsics.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/gcc-8.intrinsics.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/python2.7.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/python3.8.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/qt4.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/qt5_11.imp"
    "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/qt5_4.imp"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/home/ptaku/serweryt/Tibia/silnik/iwyu/iwyu/include-what-you-use.1")
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/ptaku/serweryt/Tibia/silnik/iwyu/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
