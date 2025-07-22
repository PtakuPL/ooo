#!/bin/bash

declare -A includes
includes["std::list<Node>"]="#include <list>"
includes["mio::mmap_source"]="#include <mio/mmap.hpp>"
includes["lua_State"]="#include \"lua/global/shared_object.hpp\""
includes["pugi::xml_node"]="#include <pugixml.hpp>"

for f in $(find ./src -type f \( -name "*.cpp" -o -name "*.hpp" \)); do
  for pattern in "${!includes[@]}"; do
    if grep -q "$pattern" "$f"; then
      include="${includes[$pattern]}"
      if ! grep -q "$include" "$f"; then
        sed -i "1i$include" "$f"
        echo "Dodano $include do $f"
      fi
    fi
  done
done