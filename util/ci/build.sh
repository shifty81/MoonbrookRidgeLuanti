#!/bin/bash -e

LOG_FILE="${BUILD_LOG:-}"
if [ -n "$LOG_FILE" ]; then
	echo ">> Logging build output to $LOG_FILE"
	exec > >(tee -a "$LOG_FILE") 2>&1
fi

cmake -B build \
	-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-Debug} \
	-DENABLE_LTO=FALSE \
	-DRUN_IN_PLACE=TRUE \
	-DENABLE_GETTEXT=${CMAKE_ENABLE_GETTEXT:-TRUE} \
	-DBUILD_SERVER=${CMAKE_BUILD_SERVER:-TRUE} \
	${CMAKE_FLAGS}

cmake --build build --parallel $(($(nproc) + 1))
