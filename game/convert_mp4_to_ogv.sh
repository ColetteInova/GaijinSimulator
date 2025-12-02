#!/bin/bash

# Script para converter arquivos MP4 para OGV
# Uso: ./convert_mp4_to_ogv.sh arquivo.mp4
# Ou para converter todos os MP4 na pasta atual: ./convert_mp4_to_ogv.sh *.mp4

if [ $# -eq 0 ]; then
    echo "Uso: $0 arquivo.mp4 [arquivo2.mp4 ...]"
    echo "Ou: $0 *.mp4 (para converter todos os MP4 na pasta)"
    exit 1
fi

for input_file in "$@"; do
    if [ ! -f "$input_file" ]; then
        echo "Arquivo não encontrado: $input_file"
        continue
    fi
    
    # Remove a extensão .mp4 e adiciona .ogv
    output_file="${input_file%.mp4}.ogv"
    
    echo "Convertendo: $input_file -> $output_file"
    ffmpeg -i "$input_file" \
        -c:v libtheora -q:v 10 \
        -c:a libvorbis -q:a 6 -ar 44100 \
        -r 120 \
        -pix_fmt yuv420p \
        "$output_file"
    
    if [ $? -eq 0 ]; then
        echo "✓ Conversão concluída: $output_file"
    else
        echo "✗ Erro na conversão: $input_file"
    fi
done

echo "Processo finalizado!"
