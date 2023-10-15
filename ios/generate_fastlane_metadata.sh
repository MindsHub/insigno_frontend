rm -rf fastlane || echo "No fastlane folder to delete"
cp -r ../fastlane .
mv fastlane/metadata/android/* fastlane/metadata
rm -rf fastlane/metadata/android
# Valid directory names are: ["ar-SA", "ca", "cs", "da", "de-DE", "el", "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX", "fi", "fr-CA", "fr-FR", "he", "hi", "hr", "hu", "id", "it", "ja", "ko", "ms", "nl-NL", "no", "pl", "pt-BR", "pt-PT", "ro", "ru", "sk", "sv", "th", "tr", "uk", "vi", "zh-Hans", "zh-Hant", "appleTV", "iMessage", "default"]
mv fastlane/metadata/it-IT fastlane/metadata/it
mkdir fastlane/screenshots

cd fastlane/metadata
for lang in * ; do
    if [ -d "$lang" ]; then
        echo "Handling $lang"
        pushd "$lang"
        cat full_description.txt | sed 's|<[a-zA-Z0-9/]*>||g' > description.txt
        rm full_description.txt
        mv short_description.txt promotional_text.txt
        rm title.txt
        mv changelogs/$1.txt release_notes.txt || echo "Release notes $1 not found for language $lang"
        rm -rf changelogs

        ls ../../
        mkdir ../../screenshots/$lang
        pushd images/phoneScreenshots
        for img in * ; do
            if [ -f "$img" ]; then
                # "1242:2688:iPhone (6.5-inch)" seems not to be needed
                for device in "1290:2796:iPhone (6.7-inch)" "1242:2208:iPhone (5.5-inch)" \
                "2048:2732:iPad Pro (12.9-inch) (2nd generation)" \
                "2048:2732:iPad Pro (12.9-inch) (6th generation)" ; do
                    WIDTH="$(cut -d: -f1 <<<$device)"
                    HEIGHT="$(cut -d: -f2 <<<$device)"
                    NAME="$(cut -d: -f3 <<<$device)"
                    ffmpeg -i "$img" -vf \
                    "scale=iw*min($WIDTH/iw\,$HEIGHT/ih):ih*min($WIDTH/iw\,$HEIGHT/ih), pad=$WIDTH:$HEIGHT:($WIDTH-iw*min($WIDTH/iw\,$HEIGHT/ih))/2:($HEIGHT-ih*min($WIDTH/iw\,$HEIGHT/ih))/2" \
                    "../../../../screenshots/$lang/${NAME}_$img"
                done
            fi
        done

        popd
        rm -rf images
        popd
    fi
done