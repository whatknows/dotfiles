#####
# FINDER EXTENSION PERMISSIONS
#####

QUICKLOOK_PACKAGES=(
    QLStephen
    QLColorCode
    qlImageSize
    WebpQuickLook
    QuickLookJSON
    QuickLookCSV
    QLPrettyPatch
    QLMarkdown
)
for p in ${QUICKLOOK_PACKAGES[@]}
do
  sudo xattr -cr ~/Library/QuickLook/${p}.qlgenerator
done
sudo qlmanage -r
sudo qlmanage -r cache
echo "Remember: You need to restart Finder for QuickLook extensions to take effect."
