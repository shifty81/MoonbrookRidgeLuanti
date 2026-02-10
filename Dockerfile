ARG DOCKER_IMAGE=alpine:3.19
FROM $DOCKER_IMAGE AS dev

ENV LUAJIT_VERSION v2.1

RUN apk add --no-cache git build-base cmake curl-dev zlib-dev zstd-dev \
		sqlite-dev postgresql-dev hiredis-dev leveldb-dev \
		gmp-dev jsoncpp-dev ninja ca-certificates

WORKDIR /usr/src/
RUN git clone --recursive https://github.com/jupp0r/prometheus-cpp && \
		cd prometheus-cpp && \
		cmake -B build \
			-DCMAKE_INSTALL_PREFIX=/usr/local \
			-DCMAKE_BUILD_TYPE=Release \
			-DENABLE_TESTING=0 \
			-GNinja && \
		cmake --build build && \
		cmake --install build && \
	cd /usr/src/ && \
	git clone --recursive https://github.com/libspatialindex/libspatialindex && \
		cd libspatialindex && \
		cmake -B build \
			-DCMAKE_INSTALL_PREFIX=/usr/local && \
		cmake --build build && \
		cmake --install build && \
	cd /usr/src/ && \
	git clone --recursive https://luajit.org/git/luajit.git -b ${LUAJIT_VERSION} && \
		cd luajit && \
		make amalg && make install && \
	cd /usr/src/

FROM dev as builder

COPY .git /usr/src/moonbrook_ridge/.git
COPY CMakeLists.txt /usr/src/moonbrook_ridge/CMakeLists.txt
COPY README.md /usr/src/moonbrook_ridge/README.md
COPY minetest.conf.example /usr/src/moonbrook_ridge/minetest.conf.example
COPY builtin /usr/src/moonbrook_ridge/builtin
COPY cmake /usr/src/moonbrook_ridge/cmake
COPY doc /usr/src/moonbrook_ridge/doc
COPY fonts /usr/src/moonbrook_ridge/fonts
COPY games /usr/src/moonbrook_ridge/games
COPY lib /usr/src/moonbrook_ridge/lib
COPY misc /usr/src/moonbrook_ridge/misc
COPY po /usr/src/moonbrook_ridge/po
COPY src /usr/src/moonbrook_ridge/src
COPY irr /usr/src/moonbrook_ridge/irr
COPY textures /usr/src/moonbrook_ridge/textures

WORKDIR /usr/src/moonbrook_ridge
RUN cmake -B build \
		-DCMAKE_INSTALL_PREFIX=/usr/local \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_SERVER=TRUE \
		-DENABLE_PROMETHEUS=TRUE \
		-DBUILD_UNITTESTS=FALSE -DBUILD_BENCHMARKS=FALSE \
		-DBUILD_CLIENT=FALSE \
		-GNinja && \
	cmake --build build && \
	cmake --install build

FROM $DOCKER_IMAGE AS runtime

RUN apk add --no-cache curl gmp libstdc++ libgcc libpq jsoncpp zstd-libs \
				sqlite-libs postgresql hiredis leveldb && \
	adduser -D moonbrook --uid 30000 -h /var/lib/moonbrook_ridge && \
	chown -R moonbrook:moonbrook /var/lib/moonbrook_ridge

WORKDIR /var/lib/moonbrook_ridge

COPY --from=builder /usr/local/share/luanti /usr/local/share/luanti
COPY --from=builder /usr/local/bin/luantiserver /usr/local/bin/moonbrook_ridgeserver
COPY --from=builder /usr/local/share/doc/luanti/minetest.conf.example /etc/moonbrook_ridge/moonbrook_ridge.conf
COPY --from=builder /usr/local/lib/libspatialindex* /usr/local/lib/
COPY --from=builder /usr/local/lib/libluajit* /usr/local/lib/
USER moonbrook:moonbrook

EXPOSE 30000/udp 30000/tcp
VOLUME /var/lib/moonbrook_ridge/ /etc/moonbrook_ridge/

ENTRYPOINT ["/usr/local/bin/moonbrook_ridgeserver"]
CMD ["--config", "/etc/moonbrook_ridge/moonbrook_ridge.conf"]
