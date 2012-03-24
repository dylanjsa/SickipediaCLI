# Silly make 
#
#
clean :
	xcodebuild -project SickipediaCLI.xcodeproj -alltargets clean
compile : clean
	xcodebuild -project SickipediaCLI.xcodeproj -alltargets
run : compile
	./build/Release/SickipediaCLI
