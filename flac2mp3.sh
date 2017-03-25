#!/bin/bash

# flac2mp3.sh — скипт для конвертации аудио файлов из FLAC в mp3 с сохранением ID3 тегов
#
# Умеет:
# - обрабатываеть папки и вложенные папки
# - сохраянет структуру папок при конвертации
# - создает ID3v2 теги для mp3 из информации во flac-файах
#
# Зависимости:
# - lame
# - flac
#
#
# Пример вызова:
#
#	с указанием необходимого битрейта, больше параметров в lame --longhelp
#	flac2mp3.sh /path/flac/albums /path/mp3/albums "-b 256 -h"
#
#	без дополнительных параметров, из текущей папки в текущую папку, mp3 файлы будут лежать рядом с flac
#	flac2mp3.sh ./ ./
# 

# Настройки LAME по-умолчанию
DEFAULT_LAME="-b 320 -h"

# создание параметров ID3 тегов для lame из metaflac
function get_id3_in_flac()
{
	flac_file="$1"

	metaflac --export-tags-to - "$flac_file" | while read -d $'\n' tag; do
		tag_name=$(echo "$tag" | awk -F= '{ print $1 }')
		tag_value=$(echo "$tag" | awk -F= '{ print $2 }' | sed 's/"/\\"/g')

		case "$tag_name" in
			TITLE)
				echo -n " --tt \"$tag_value\""
				;;
			ARTIST)
				echo -n " --ta \"$tag_value\""
				;;
			ALBUM)
				echo -n " --tl \"$tag_value\""
				;;
			GENRE)
				echo -n " --tg \"$tag_value\""
				;;
			DATE)
				echo -n " --ty \"$tag_value\""
				;;
			TRACKNUMBER)
				echo -n " --tn \"$tag_value\""
				;;
			title)
				echo -n " --tt \"$tag_value\""
				;;
			artist)
				echo -n " --ta \"$tag_value\""
				;;
			album)
				echo -n " --tl \"$tag_value\""
				;;
			genre)
				echo -n " --tg \"$tag_value\""
				;;
			date)
				echo -n " --ty \"$tag_value\""
				;;
			tracknumber)
				echo -n " --tn \"$tag_value\""
				;;
		esac
	done
}

# Входная функция
function main()
{
	input_dir=$1
	output_dir=$2
	lame_opts=$3

	# Надо указывать папки исходную и назначения
	if [[ -z "$input_dir" || -z "$output_dir" ]]; then
		echo "Usage: $0 <input_dir> <output_dir> [lame_opts]"
		echo "Example: $0 /path/flac/albums /path/need/mp3 \"-b 320 -h\""
		exit 1
	fi

	# Опции по умолчанию, если не установлены явно
	if [[ -z "$lame_opts" ]]; then
		lame_opts=$DEFAULT_LAME
	fi

	# Существование исходной папки
	if [ ! -d "$input_dir" ]; then
		echo "<input_dir> do not exists"
		return 1
	fi

	# Создание папки назначения при её отсутствии
	if [ ! -d "$output_dir" ]; then
		echo "<output_dir> do not exists. Create <output_dir>"
		mkdir -p "$output_dir"
	fi

	# Определяем как будут разделяться строки. Нам нужны только переносы, чтобы игнирировлись пробелы
	OIFS=$IFS; IFS=$'\n'


	# Перебираем в цикле файлы с расширением flac, отсортированные по имени
	for f in $(find "$input_dir" -name "*.flac" | sort); do
		flac_file_name=`basename "$f"`
		
		# файл с заменой
		new_mp3_file=$output_dir${f/${input_dir}/}

		# создадим нужную папку для mp3
		need_mp3_dir=${new_mp3_file/${flac_file_name}/}

		if [ ! -d "$need_mp3_dir" ]; then
			echo "Create dir - '$need_mp3_dir'"
			mkdir -p "$need_mp3_dir"
		fi

		# имя файла заканчивается на mp3
		new_mp3_file="${new_mp3_file%.*}".mp3

		id3_tags=$(get_id3_in_flac "$f")

		# Выполнение
		eval "flac -cd \"$f\" | lame $lame_opts $id3_tags - \"$new_mp3_file\""
	done
}


echo 'Start processing...'

main "$@"

echo 'Done!'