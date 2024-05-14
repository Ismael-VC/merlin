cd src
uxnasm monocycle.tal ../bin/monocycle.rom
cd ..
cp bin/monocycle.rom ~/roms
uxncli bin/monocycle.rom
