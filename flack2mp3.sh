#!/bin/bash

# eyeD3

# Настройки LAME по-умолчанию
DEFAULT_LAME="-b 320 -h"

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
		lame_opts=$DEFAULT_LAME_OPTS
	fi

	# Существование исходной папки
	# if [ ! -d "$input_dir" ]; then
	# 	echo "<input_dir> do not exists"
	# 	return 1
	# fi

	# # Создание папки назначения при её отсутствии
	# if [ ! -d "$output_dir" ]; then
	# 	echo "<output_dir> do not exists. Create <output_dir>"
	# 	mkdir -p "$output_dir"
	# fi

	# Перебираем в цикле файлы с расширением flac, отсортированные по имени
	for f in $(find "$input_dir" -name "*.flac" | sort); do
		new_mp3="${f%.*}".mp3
		id3_tags=$(get_id3_in_flac "$f")
		eval "flac -cd \"$f\" | lame $DEFAULT_LAME_OPTS $id3_tags - \"$new_mp3\""; 
	done
}


echo 'Start processing'

# res=$(get_id3_in_flac "/home/ildar/download/shs/02 - Slam.flac")
# echo "-$res-"

main "$@"

echo 'End processing'