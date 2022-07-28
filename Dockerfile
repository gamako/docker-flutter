FROM alvrme/alpine-android-base:jdk11 AS gradle_builder

RUN apk --no-cache add gradle && \
    cd /tmp && \
    touch settings.gradle && \
    gradle --no-daemon wrapper --gradle-version  7.0.2 --distribution-type all && \
    ./gradlew wrapper --no-daemon && \
    rm -rf .gradle gradle  gradlew  gradlew.bat settings.gradle && \
    cd .. && \
    apk del gradle

FROM alvrme/alpine-android-base:jdk11 AS flutter

RUN apk add --no-cache xz
ENV FLUTTER_VERSION 3.0.4
ARG flutter_sdk=flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

RUN cd /opt \
    && curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${flutter_sdk} \
    && tar xf ${flutter_sdk} \
    && rm ${flutter_sdk}

FROM alvrme/alpine-android-base:jdk11

LABEL maintainer="gamako@gmail.com"

ENV BUILD_TOOLS 30.0.2
ENV PATH $PATH:${ANDROID_SDK_ROOT}/build-tools/${BUILD_TOOLS}

RUN sdkmanager \
    --sdk_root="${ANDROID_SDK_ROOT}" \
    --install \
        "build-tools;${BUILD_TOOLS}" \
        "platforms;android-29" \
        "platforms;android-30" \
        "platforms;android-31" \
    && sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" --uninstall emulator

COPY --from=gradle_builder /root/.gradle /root/.gradle
COPY --from=flutter /opt/flutter /opt/flutter
ENV PATH=/opt/flutter/bin:${PATH}
RUN flutter config --no-analytics
