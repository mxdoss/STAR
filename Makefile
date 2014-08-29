OBJECTS = PackedArray.o SuffixArrayFuns.o STAR.o Parameters.o InOutStreams.o SequenceFuns.o Genome.o Transcript.o Stats.o \
        ReadAlign.o ReadAlign_storeAligns.o ReadAlign_stitchPieces.o ReadAlign_multMapSelect.o ReadAlign_mapOneRead.o readLoad.o \
	ReadAlignChunk.o ReadAlignChunk_processChunks.o ReadAlignChunk_mapChunk.o \
	OutSJ.o outputSJ.o blocksOverlap.o ThreadControl.o sysRemoveDir.o \
        ReadAlign_maxMappableLength2strands.o binarySearch2.o\
	ReadAlign_outputAlignments.o  \
	ReadAlign_outputTranscriptSAM.o ReadAlign_outputTranscriptSJ.o ReadAlign_outputTranscriptCIGARp.o \
        ReadAlign_createExtendWindowsWithAlign.o ReadAlign_assignAlignToWindow.o ReadAlign_oneRead.o \
	ReadAlign_stitchWindowSeeds.o ReadAlign_chimericDetection.o \
        stitchWindowAligns.o extendAlign.o stitchAlignToTranscript.o alignSmithWaterman.o genomeGenerate.o \
	TimeFunctions.o ErrorWarning.o loadGTF.o streamFuns.o stringSubstituteAll.o \
        Transcriptome.o Transcriptome_quantAlign.o ReadAlign_quantTranscriptome.o \
        BAMoutput.o BAMfunctions.o ReadAlign_alignBAM.o BAMbinSortByCoordinate.o signalFromBAM.o \
        bam_cat.o
SOURCES := $(wildcard *.cpp) $(wildcard *.c)

LDFLAGS := -pthread -Lhtslib -Bstatic -lhts -Bdynamic -lz
LDFLAGS_static := -static -static-libgcc $(LDFLAGS)
LDFLAGS_gdb := $(LDFLAGS)

SVNDEF := -D'SVN_VERSION_COMPILED="STAR_2.4.0b"'
COMPTIMEPLACE := -D'COMPILATION_TIME_PLACE="$(shell echo `date` $(HOSTNAME):`pwd`)"'

CCFLAGS_common := -pipe -std=c++0x -Wall -Wextra -fopenmp $(SVNDEF) $(COMPTIMEPLACE) $(OPTIMFLAGS) $(OPTIMFLAGS1)
CCFLAGS_main := -O3 $(CCFLAGS_common)
CCFLAGS_gdb :=  -O0 -g $(CCFLAGS_common)

CC :=g++


%.o : %.cpp
	$(CC) -c $(CCFLAGS) $<

%.o : %.c
	$(CC) -c $(CCFLAGS) $<

all: STAR

.PHONY: clean
clean:
	rm -f *.o STAR STARstatic Depend.list

.PHONY: cleanRelease
cleanRelease:
	rm -f *.o Depend.list
	$(MAKE) -C htslib clean

.PHONY: CLEAN
CLEAN:
	rm -f *.o STAR Depend.list
	$(MAKE) -C htslib clean


ifneq ($(MAKECMDGOALS),clean)
ifneq ($(MAKECMDGOALS),STARforMac)
ifneq ($(MAKECMDGOALS),STARforMacGDB)
Depend.list: $(SOURCES) parametersDefault.xxd htslib
	echo $(SOURCES)
	/bin/rm -f ./Depend.list
	$(CC) $(CCFLAGS_common) -MM $^ >> Depend.list
include Depend.list
endif
endif
endif

htslib : htslib/libhts.a

htslib/libhts.a :
	$(MAKE) -C htslib lib-static

parametersDefault.xxd: parametersDefault
	xxd -i parametersDefault > parametersDefault.xxd

STAR : CCFLAGS=$(CCFLAGS_main)
STAR : Depend.list parametersDefault.xxd $(OBJECTS)
	$(CC) -o STAR $(CCFLAGS) $(OBJECTS) $(LDFLAGS)
	$(CC) -o STARstatic $(OBJECTS) $(CCFLAGS) $(LDFLAGS_static)

STARstatic : CCFLAGS=$(CCFLAGS_main)
STARstatic : Depend.list parametersDefault.xxd $(OBJECTS)
	$(CC) -o STARstatic $(OBJECTS) $(CCFLAGS) $(LDFLAGS_static)

STARlong : CCFLAGS=-D'COMPILE_FOR_LONG_READS' $(CCFLAGS_main)
STARlong : Depend.list parametersDefault.xxd $(OBJECTS)
	$(CC) -o STAR $(CCFLAGS) $(OBJECTS) $(LDFLAGS)

STARlongStatic : CCFLAGS=-D'COMPILE_FOR_LONG_READS' $(CCFLAGS_main)
STARlongStatic : Depend.list parametersDefault.xxd $(OBJECTS)
	$(CC) -o STARstatic $(CCFLAGS) $(LDFLAGS_static) $(OBJECTS)


STARforMac : CCFLAGS=-D'COMPILE_FOR_MAC' -I ./Mac_Include/ $(CCFLAGS_main)
STARforMac : parametersDefault.xxd $(OBJECTS)
	$(CC) -o STAR $(CCFLAGS) $(LDFLAGS) $(OBJECTS)

STARforMacGDB : CCFLAGS=-D'COMPILE_FOR_MAC' -I ./Mac_Include/ $(CCFLAGS_gdb)
STARforMacGDB : parametersDefault.xxd $(OBJECTS)
	$(CC) -o STAR $(CCFLAGS_gdb) $(OBJECTS) $(LDFLAGS_gdb)

gdb : CCFLAGS= $(CCFLAGS_gdb)
gdb : Depend.list parametersDefault.xxd $(OBJECTS)
	$(CC) -o STAR $(CCFLAGS_gdb) $(OBJECTS) $(LDFLAGS_gdb) 

gdb-long : CCFLAGS= -D'COMPILE_FOR_LONG_READS' $(CCFLAGS_gdb)
gdb-long : Depend.list parametersDefault.xxd $(OBJECTS)
	$(CC) -o STAR $(CCFLAGS) $(LDFLAGS_gdb) $(OBJECTS)

localChains : CCFLAGS=-D'OUTPUT_localChains' $(CCFLAGS_main)
localChains : Depend.list parametersDefault.xxd $(OBJECTS)
	$(CC) -o STAR $(CCFLAGS) $(LDFLAGS) $(OBJECTS)


