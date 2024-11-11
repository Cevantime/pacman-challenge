ITCH_GAME_SLUG=pacman-challenge
ITCH_GAME_USERNAME_SLUG=cevantime


WEB_EXPORT_FOLDER=web_export
LINUX_EXPORT_FOLDER=linux_export
WINDOWS_EXPORT_FOLDER=windows_export

WEB_PRESET_NAME="Web"
LINUX_PRESET_NAME="Linux"
WINDOWS_PRESET_NAME="Windows Desktop"

# GODOT_EXECUTABLE=godot
GODOT_EXECUTABLE=/home/cevantime/Bureau/Godot_v4.3-stable_linux.x86_64

web:
	rm -rf ${WEB_EXPORT_FOLDER}
	mkdir ${WEB_EXPORT_FOLDER}
	touch ${WEB_EXPORT_FOLDER}/index.html
	mkdir ${WEB_EXPORT_FOLDER}/web_nothreads_release
	${GODOT_EXECUTABLE} --export-release --headless ${WEB_PRESET_NAME} ${WEB_EXPORT_FOLDER}/index.html
	if [ -f ${WEB_EXPORT_FOLDER}/web_nothreads_release/index.html ]; then \
		mv ${WEB_EXPORT_FOLDER}/web_nothreads_release/index.html ${WEB_EXPORT_FOLDER}/index.html; \
		${GODOT_EXECUTABLE} --export-release --headless ${WEB_PRESET_NAME} ${WEB_EXPORT_FOLDER}/index.html; \
	fi
	if [ -f ${WEB_EXPORT_FOLDER}/web_nothreads_release/index.html ]; then \
		rm ${WEB_EXPORT_FOLDER}/web_nothreads_release/index.html; \
		mv ${WEB_EXPORT_FOLDER}/web_nothreads_release/* web_export; \
		rmdir ${WEB_EXPORT_FOLDER}/web_nothreads_release; \
	fi

	butler push ${WEB_EXPORT_FOLDER} ${ITCH_GAME_USERNAME_SLUG}/${ITCH_GAME_SLUG}:web
	rm -rf ${WEB_EXPORT_FOLDER}

linux:
	rm -rf ${LINUX_EXPORT_FOLDER}
	mkdir ${LINUX_EXPORT_FOLDER}
	${GODOT_EXECUTABLE} --export-release --headless ${LINUX_PRESET_NAME} ${LINUX_EXPORT_FOLDER}/${ITCH_GAME_SLUG}.x86_64
	butler push ${LINUX_EXPORT_FOLDER} ${ITCH_GAME_USERNAME_SLUG}/${ITCH_GAME_SLUG}:linux
	rm -rf ${LINUX_EXPORT_FOLDER}

windows:
	rm -rf ${WINDOWS_EXPORT_FOLDER}
	mkdir ${WINDOWS_EXPORT_FOLDER}
	${GODOT_EXECUTABLE} --export-release --headless ${WINDOWS_PRESET_NAME} ${WINDOWS_EXPORT_FOLDER}/${ITCH_GAME_SLUG}.exe
	butler push ${WINDOWS_EXPORT_FOLDER} ${ITCH_GAME_USERNAME_SLUG}/${ITCH_GAME_SLUG}:windows
	rm -rf ${WINDOWS_EXPORT_FOLDER}

all: linux windows web
	@echo "all exports have been done"
