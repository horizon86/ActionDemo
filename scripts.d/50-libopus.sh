#!/bin/bash

OPUS_REPO="https://github.com/xiph/opus.git"
OPUS_COMMIT="d633f523e36e3b6d01cc6d57386458d770d618be"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPUS_REPO" "$OPUS_COMMIT" opus
    cd opus

    ./autogen.sh || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --disable-extra-programs
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ..
    rm -rf opus
}

ffbuild_configure() {
    echo --enable-libopus
}

ffbuild_unconfigure() {
    echo --disable-libopus
}
