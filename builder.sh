#/usr/bin/env bash
git clone --depth=1 https://github.com/ytdl-org/youtube-dl.git crap
apply patches/minimize patch
cd crap
git apply "../patches/minimize.patch"
cd youtube_dl/extractor
mkdir tmp
mv __init__.py common.py commonmistakes.py commonprotocols.py youtube.py tmp
rm *.py
mv tmp/* .
cp ../../../patches/extractors.py .
rm -rf tmp
cd ../..
make
mv youtube-dl ../ytd
cd ..
rm -rf crap
