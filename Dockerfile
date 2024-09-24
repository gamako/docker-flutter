FROM alvrme/alpine-android-base:jdk11 AS gradle_builder

RUN apk --no-cache add gradle && \
    cd /tmp && \
    touch settings.gradle && \
    gradle --no-daemon wrapper --gradle-version  7.6.3 --distribution-type all && \
    ./gradlew wrapper --no-daemon && \
    rm -rf .gradle gradle  gradlew  gradlew.bat settings.gradle && \
    cd .. && \
    apk del gradle

FROM alvrme/alpine-android-base:jdk11 AS flutter

RUN apk add --no-cache xz
ENV FLUTTER_VERSION=3.24.0
ARG flutter_sdk=flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

RUN cd /opt \
    && curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${flutter_sdk} \
    && tar xf ${flutter_sdk} \
    && rm ${flutter_sdk}

FROM alvrme/alpine-android-base:jdk11

LABEL maintainer="gamako@gmail.com"

ENV BUILD_TOOLS=30.0.3
ENV PATH=$PATH:${ANDROID_SDK_ROOT}/build-tools/${BUILD_TOOLS}

RUN yes | sdkmanager \
    --sdk_root="${ANDROID_SDK_ROOT}" \
    --install \
        "build-tools;${BUILD_TOOLS}" \
        "platforms;android-32" \
        "platforms;android-33" \
        "platforms;android-34" \
        "platforms;android-35" \
        "platform-tools" \
        "emulator"


COPY --from=gradle_builder /root/.gradle /root/.gradle
COPY --from=flutter /opt/flutter /opt/flutter
ENV PATH=/opt/flutter/bin:${PATH}
RUN flutter config --no-analytics
RUN git config --global --add safe.directory /opt/flutter
