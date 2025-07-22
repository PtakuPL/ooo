#!/bin/bash

# Funkcja generująca nazwę include guard na bazie ścieżki pliku
generate_guard_name() {
    local file_path="$1"
    # Zamiana znaków niealfanumerycznych na _
    local guard=$(echo "$file_path" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9]/_/g')
    echo "${guard}_"
}

# Szukanie plików .hpp i .hpp.bak
find . -type f \( -name "*.hpp" -o -name "*.hpp.bak" \) | while read -r file; do
    # Sprawdzenie czy plik zawiera #pragma once lub #ifndef w pierwszych 20 liniach
    if ! head -n 20 "$file" | grep -qE '#pragma once|#ifndef'; then
        guard_name=$(generate_guard_name "$file")
        echo "Dodaję include guard do: $file z nazwą: $guard_name"

        # Tworzymy plik tymczasowy z dodanym include guard
        {
            echo "#ifndef $guard_name"
            echo "#define $guard_name"
            echo ""
            cat "$file"
            echo ""
            echo "#endif // $guard_name"
        } > "$file.tmp" && mv "$file.tmp" "$file"
    else
        echo "Plik $file już posiada include guard lub pragma once, pomijam."
    fi
done