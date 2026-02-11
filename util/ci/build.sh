#!/bin/bash -e

set -o pipefail

LOG_FILE="${BUILD_LOG:-}"
run_cmd() {
	"$@"
}
if [ -n "$LOG_FILE" ]; then
	LOG_DIR="$(dirname "$LOG_FILE")"
	if ! mkdir -p "$LOG_DIR"; then
		echo ">> Unable to create log directory: $LOG_DIR" >&2
		exit 1
	fi
	if ! : > "$LOG_FILE"; then
		echo ">> Unable to write to log file: $LOG_FILE" >&2
		exit 1
	fi
	echo ">> Logging build output to $LOG_FILE"
	run_cmd() {
		"$@" 2>&1 | tee -a "$LOG_FILE"
	}
fi

run_cmd cmake -B build \
	-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-Debug} \
	-DENABLE_LTO=FALSE \
	-DRUN_IN_PLACE=TRUE \
	-DENABLE_GETTEXT=${CMAKE_ENABLE_GETTEXT:-TRUE} \
	-DBUILD_SERVER=${CMAKE_BUILD_SERVER:-TRUE} \
	${CMAKE_FLAGS}

run_cmd cmake --build build --parallel $(($(nproc) + 1))
