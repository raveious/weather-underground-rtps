# Build environment for the application
FROM raveious/fastrtps as builder

# Install build dependences
RUN apk add --update --no-cache git cmake make build-base gcc g++ linux-headers openssl openssl-dev boost boost-dev

# Build cpprestsdk
RUN git clone --depth 1 --recurse-submodules --single-branch https://github.com/Microsoft/cpprestsdk.git /home/cpprestsdk
WORKDIR /home/cpprestsdk/build
RUN cmake .. && make -j && make install

# Build forcaster
RUN git clone --depth 1 --recurse-submodules --single-branch https://github.com/raveious/darksky-rtps.git /home/darksky-rtps
WORKDIR /home/darksky-rtps/build
RUN cmake .. && make

# Production container should only container the executable
FROM raveious/fastrtps

# Exposing known ports for this node
EXPOSE 44084/udp 17900/udp 17910/udp 17911/udp

RUN apk add --update --no-cache boost

#COPY --from=builder /usr/local/include/* /usr/local/include/
COPY --from=builder /usr/local/lib64/* /usr/local/lib64/
COPY --from=builder /usr/local/lib/* /usr/local/lib/

COPY --from=builder /home/darksky-rtps/build/forcaster/forcaster /usr/local/bin/forcaster

CMD forcaster
