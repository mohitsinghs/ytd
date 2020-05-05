#/usr/bin/env bash
# clone youtube-dl crap
git clone --depth=1 https://github.com/ytdl-org/youtube-dl.git crap
# apply minimize patch
cd crap
git apply "../minimize.patch"
# clean thing up
cd youtube_dl/extractor
mkdir tmp
mv __init__.py common.py commonmistakes.py commonprotocols.py extractors.py youtube.py tmp
rm *.py
mv tmp/* .
rm -rf tmp
# create our beautiful ytd out of it
cd ../..
make
mv youtube-dl ../ytd
cd ..
# kick the crap out
rm -rf crap
