#!/bin/sh

readonly BENCHMARK_LOCALIZATION_LPROJ=$1
if [ ! "$BENCHMARK_LOCALIZATION_LPROJ" ]; then
    echo "error: benchmark lproj name must be passed as first argument"
    exit 1
fi

readonly LOCALIZATION_FILE_NAME=$2
if [ ! "$LOCALIZATION_FILE_NAME" ]; then
    echo "error: name of the localization file must be passed as second argument"
    exit 2
fi

readonly localizationFiles=($(find . -not -path "*.bundle*" -name "$LOCALIZATION_FILE_NAME" -type f))
if [ "${#localizationFiles[@]}" == 0 ]; then
    echo "error: localization is not supported in the project"
    exit 3
fi

readonly benchmarkLocalizationFile=($(
    for filePath in "${localizationFiles[@]}"; do
        [[ $filePath == *"/$BENCHMARK_LOCALIZATION_LPROJ/$LOCALIZATION_FILE_NAME" ]] && echo "$filePath"
    done
))
if [ ! "$benchmarkLocalizationFile" ]; then
    echo "error: unable to find localization benchmark file"
    exit 4
fi

readonly reviewLocalizationFiles=($(
    for filePath in "${localizationFiles[@]}"; do
        [ $filePath != "$benchmarkLocalizationFile" ] && result+=("$filePath")
    done
    echo "${result[@]}"
))


benchamrkTokens=($(cat $benchmarkLocalizationFile | grep '^".*"' | cut -d '=' -f 1 | xargs))

for filePath in "${reviewLocalizationFiles[@]}"; do

    reviewTokens=($(cat $filePath | grep '^".*"' | cut -d '=' -f 1 | xargs))
    missingTokens=()
    extraTokens=()

    for benchmarkToken in "${benchamrkTokens[@]}"; do
        [[ ! "${reviewTokens[@]}" =~ $benchmarkToken ]] && missingTokens+=("$benchmarkToken")
    done

    for reviewToken in "${reviewTokens[@]}"; do
        [[ ! "${benchamrkTokens[@]}" =~ $reviewToken ]] && extraTokens+=("$reviewToken")
    done

    missingCount="${#missingTokens[@]}"
    extraCount="${#extraTokens[@]}"
    tableSize=$(( missingCount > extraCount ? missingCount : extraCount))

    if [ ! $tableSize == 0 ]; then
        echo "warning: $filePath is inconsistent with base localization file."
        (
            printf "Missing:\tExtra:\n"
            for ((i=0;i<tableSize;i++)); do
                missingColumn=$([[ ${missingTokens[i]} ]] && echo ${missingTokens[i]} || echo "\02\03")
                extraColumn=$([[ ${extraTokens[i]} ]] && echo ${extraTokens[i]} || echo "\02\03")
                printf "%s\t%s\n" "${missingColumn}" "${extraColumn}"
            done
        ) | column -t
        printf "\n"
    fi

done
